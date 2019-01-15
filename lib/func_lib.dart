import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './main.dart';

// String dataPath = "/storage/emulated/0/expense_data/data.json";

Function isEqual = const ListEquality().equals;

bool isIdenticalRecord(Map<String, String> record1, Map<String, String> record2) {
  if (isEqual(record1.keys.toList(), record2.keys.toList())) {
    return (record1["name"] == record2["name"] &&
            record1["amount"] == record2["amount"] &&
            record1["payMode"] == record2["payMode"] &&
            record1["note"] == record2["note"]);
  }

  return false;
}

int indexOfRecord(List<Map> recordList, Map<String, String> record) {
  int len = recordList.length;
  
  for (int i = 0; i < len; i++) {
    if (isIdenticalRecord(Map<String, String>.from(recordList[i]), record)) {
      return i;
    }
  }

  return -1;
}

Future<Null> vibrate() async {
  await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
}

List<String> getSortedDataKeys({Map<String, dynamic> expenseData}) {
  List<String> keyList = [];

  if (expenseData == null)
    expenseData = data;

  keyList = List<String>.from(expenseData["records"].keys.toList());
  keyList.sort();
  keyList = keyList.reversed.toList();

  return keyList;
}

String getFullDate(String date) {
  List<String> dateSplit = date.split('/');
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"];

  return "${dateSplit[2]} ${months[int.parse(dateSplit[1]) - 1]} ${dateSplit[0]}";
}

String weekday(String date) {
  String weekday;

  switch (DateTime.parse(date.replaceAll('/', '-')).weekday) {
    case 1:
      weekday = "Monday";
      break;
    
    case 2:
      weekday = "Tuesday";
      break;

    case 3:
      weekday = "Wednesday";
      break;
    
    case 4:
      weekday = "Thursday";
      break;
    
    case 5:
      weekday = "Friday";
      break;
    
    case 6:
      weekday = "Saturday";
      break;
    
    case 7:
      weekday = "Sunday";
      break;
  }

  return weekday;
}

String expandPaymentMode(String payMode) {
  switch(payMode) {
    case "cash":
      return "Cash";

    case "e_wallet":
      return "E-Wallet";

    case "online":
      return "Online Banking";

    case "c_card":
      return "Credit Card";

    case "d_card":
      return "Debit Card";

    case "unpaid":
      return "Unpaid";

    default:
      return "";
    }
}

IconData getPaymentIcon(String paymentMode) {
  if (paymentMode == 'cash') {
    return Icons.monetization_on;
  }
  else if (paymentMode == 'e_wallet') {
    return Icons.account_balance_wallet;
  }
  else if (paymentMode == 'online') {
    return Icons.vpn_lock;
  }
  else if (paymentMode == 'c_card') {
    return Icons.credit_card;
  }
  else if (paymentMode == 'd_card') {
    return Icons.card_membership;
  }
  else if (paymentMode == 'unpaid') {
    return Icons.warning;
  }

  return Icons.money_off;
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get localFile async {
  String path = await localPath;
  return File("$path/data.json");
}

Future<String> saveData([Map<String, dynamic> expenseData]) async {
  File dataFile = await localFile;
  String dataString;

  if (expenseData == null)
    dataString = json.encode(data);
  else
    dataString = json.encode(expenseData);
    
  dataFile.writeAsString(dataString);
  return dataString;
}

List<Color> getColorList(String paymentMode) {
  if (paymentMode == 'cash') {
    return [
      Colors.orangeAccent,
      Colors.deepOrange,
    ];
  }
  else if (paymentMode == 'e_wallet') {
    return [
      Colors.green,
      Colors.lime[600],
    ];
  }
  else if (paymentMode == 'online') {
    return [
      Colors.purpleAccent,
      Colors.deepPurple,
    ];
  }
  else if (paymentMode == 'c_card') {
    return [
      Colors.teal,
      Colors.blueGrey,
    ];
  }
  else if (paymentMode == 'd_card') {
    return [
      Colors.pink,
      Colors.redAccent,
    ];
  }

  else if (paymentMode == 'unpaid') {
    return [
      Colors.red,
      Colors.deepOrange
    ];
  }

  return [
    Colors.black,
    Colors.white,
  ];
}

LinearGradient getGradient(String paymentMode) {
  return LinearGradient(
    colors: getColorList(paymentMode)
  );
}

void handleData(Map<String, dynamic> expenseData) {
  if (!expenseData.keys.contains("records")) {
    // If `data` from Expense Monitor v1.0
    // Converting the old json format to new one...

    List<String> dateKeys = expenseData.keys.toList();

    for (int i = 0; i < dateKeys.length; i++) {
      String date = dateKeys[i];
      data["records"][date] = [];
      
      for (int j = 0; j < expenseData[date].length; j++) {
        data["records"][date].add({
          "name": expenseData[date][j][0],
          "amount": expenseData[date][j][1],
          "payMode": expenseData[date][j][2],
          "note": "",
        });
      }
    }
  }
  else {
    data = expenseData;
  }
}

int removeRecord(BuildContext context, Map<String, String> record, String date) {
  int index = indexOfRecord(List<Map>.from(data["records"][date]), record);
  print(index);

  data["records"][date].removeAt(index);
  print(data["records"][date]);

  if (data["records"][date].isEmpty) {
    data["records"].remove(date);
  }

  return index;
}

Map<String, String> getRecord(Map<String, dynamic> expenseData, String date, int recordIndex) {
  return Map<String, String>.from(expenseData["records"][date][recordIndex]);
}

Widget buildCard(Map<String, dynamic> expenseData, String date, int recordIndex, {List<String> sortedDataKeys}) {
  String symbolType = expenseData["settings"]["symbol_type"];
  String currencyCode = expenseData["settings"]["currency"];
  Map<String, dynamic> currency = currencyList[currencyCode];
  Map<String, String> record = getRecord(expenseData, date, recordIndex);

  List<String> _dataKeys = (sortedDataKeys != null)
                              ? sortedDataKeys
                              : getSortedDataKeys(expenseData: expenseData);

  int dateIndex = _dataKeys.indexOf(date);
  
  return Card(
    color: Colors.transparent,
    elevation: 4.0,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10.0
        ),
        gradient: getGradient(record["payMode"])
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 10.0
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Hero(
              tag: '${_dataKeys[dateIndex]}-$recordIndex-icon',
              child: Icon(getPaymentIcon(record["payMode"]),
                color: Colors.white,
                size: 27.0,
              ),
            ),
            radius: 25.0,
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0,
              right: 20.0
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("${record["name"]}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    color: Colors.white,
                  )
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 3.0),
              ),
              Text("${currency[symbolType]} ${record["amount"]}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 6.0),
              ),
              Row(
                children: <Widget>[
                  (record["payMode"] != "unpaid")
                    ? Icon(Icons.verified_user,
                      color: Colors.white70,
                      size: 15.0,
                    )
                    : Icon(Icons.error,
                      color: Colors.white70,
                      size: 15.0,
                    ),
                  Padding(
                    padding:
                        EdgeInsets.only(right: 5.0),
                  ),
                  Text(expandPaymentMode(record["payMode"]),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.0,
                    ),
                  ),
                ]
              ),
            ],
          ),
        ],
      ),
    )
  );
}

bool mapContainsKeys(Map map, List<String> keys) {
  for (String key in keys) {
    if (!map.containsKey(key))
      return false;
  }

  return true;
}

/// Checks if [expenseData] is a valid Map of expense data.
/// 
/// This function does not check for exact eqality of field names
/// for the sake of future changes to the structure of data...
/// 
/// Checking is limited to outer field names only...
bool isValidData(Map<String, dynamic> expenseData) {
  if (expenseData == null)
    return false;

  if (mapContainsKeys(expenseData, ['settings', 'records']) && expenseData.isNotEmpty) {
    // Check if given keys match
    // Check if [expenseData] is empty
    return true;
  }

  return false;
}

List<Widget> getListUI(Map<String, dynamic> expenseData) {
  List<Widget> listUI = [];
  List<String> sortedDataKeys = getSortedDataKeys(expenseData: expenseData);

  assert(expenseData != null);

  for (int dateIndex = 0; dateIndex < sortedDataKeys.length; dateIndex++) {
    String date = sortedDataKeys[dateIndex];
    
    listUI.add(
      ListTile(
        title: Text("${getFullDate(date)}  (${weekday(date)})",
          style: TextStyle(
            color: Colors.blueAccent,
          ),
        ),
      )
    );

    for (int recordIndex = 0; recordIndex < expenseData["records"][date].length; recordIndex++) {
      listUI.add(
        buildCard(expenseData, date, recordIndex, sortedDataKeys: sortedDataKeys)
      );
    }
  }

  return listUI;
}

class MyGoogleIdentity extends GoogleIdentity {
  MyGoogleIdentity(GoogleSignInAccount user) {
    this.user = user;
  }

  GoogleSignInAccount user;
  
  get id => user.id;
  get displayName => user.displayName;
  get email => user.email;
  get photoUrl => user.photoUrl;
}

Future<bool> handleSignIn(FirebaseAuth auth) async {
  try {
    GoogleSignInAccount googleUser = await googleSignIn.signInSilently();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    FirebaseUser firebaseUser = await auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print("signed in " + firebaseUser.displayName);
    user = firebaseUser;

    return true;
  }
  catch (e) {
    print(e);
    return false;
  }
}

enum SignInStatus {
  notSignedIn,
  partiallySignedIn,
  fullySignedIn
}

SignInStatus getSignInStatus(GoogleSignInAccount googleUser) {
  if (user == null) {
    if (googleUser == null) {
      // Not Signed in
      return SignInStatus.notSignedIn;
    }
    else {
      // Partially Signed in
      return SignInStatus.partiallySignedIn;
    }
  }
  else {
    // Fully Signed in
    return SignInStatus.fullySignedIn;
  }
}
