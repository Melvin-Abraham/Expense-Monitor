import 'package:flutter/material.dart';

import './main.dart';
import './func_lib.dart';

class AddRecord extends StatefulWidget {
  final Map<String, String> editRecordData;
  final String editDate;

  AddRecord({this.editDate, this.editRecordData});
  
  @override
  _AddRecordState createState() => _AddRecordState(editDate, editRecordData);
}

class _AddRecordState extends State<AddRecord> {
  static DateTime _date = DateTime.now();
  String dateStr = getDate(_date.toString());
  String _oldDate;
  String itemName = '';
  String itemPrice = '';
  String paymentMode = 'cash';
  String note = '';
  Map<String, String> newRecord = {};
  TextEditingController _itemNameController;
  TextEditingController _itemPriceController;
  TextEditingController _noteController;

  Map<String, String> editRecordData = {};
  String editDate = "";
  bool editMode = false;

  _AddRecordState(this.editDate, this.editRecordData) {
    if (this.editDate != null && this.editRecordData != null)
      editMode = true;
    
    if (editMode) {
      itemName = editRecordData["name"];
      itemPrice = editRecordData["amount"];
      paymentMode = editRecordData["payMode"];
      note = editRecordData["note"];

      _oldDate = editDate;
      dateStr = editDate;
      _date = DateTime(
        int.parse(dateStr.split('/')[0]),
        int.parse(dateStr.split('/')[1]),
        int.parse(dateStr.split('/')[2]),
      );
    }

    _itemNameController = 
      TextEditingController(
        text: itemName,
      );
      
    _itemPriceController = 
      TextEditingController(
        text: itemPrice,
      );

    _noteController = 
      TextEditingController(
        text: note,
      );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void setPayData() {
    newRecord = {
      "name": itemName,
      "amount": itemPrice,
      "payMode": paymentMode,
      "note": note
    };
  }
  
  Future<Null> _pickDate(BuildContext context) async { 
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000)
    );

    if (picked != null) {
      _date = picked;
      String datePicked = picked.toString();
      
      setState(() {
        dateStr = getDate(datePicked);
      });
    }
  }

  Future<Null> _pickPaymentMode(BuildContext context) async {
    var dialog = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Select Payment Mode",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.cash); },
              child: Row(
                children: <Widget>[
                  Icon(Icons.monetization_on),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  Text("Cash",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.e_wallet); },
              child: Row(
                children: <Widget>[
                  Icon(Icons.account_balance_wallet),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  Text("E-wallet",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.online); },
              child: Row(
                children: <Widget>[
                  Icon(Icons.vpn_lock),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  Text("Online Banking",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.c_card); },
              child: Row(
                children: <Widget>[
                  Icon(Icons.credit_card),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  Text("Credit Card",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.d_card); },
              child: Row(
                children: <Widget>[
                  Icon(Icons.card_membership),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  Text("Debit Card",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.unpaid); },
              child: Row(
                children: <Widget>[
                  Icon(Icons.warning,
                    color: Colors.redAccent,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  Text("Unpaid",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.redAccent
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }
    );

    switch(dialog) {
      case PayMode.cash:
        setPayMode('cash');
        break;
      case PayMode.e_wallet:
        setPayMode('e_wallet');
        break;
      case PayMode.online:
        setPayMode('online');
        break;
      case PayMode.c_card:
        setPayMode('c_card');
        break;
      case PayMode.d_card:
        setPayMode('d_card');
        break;
      case PayMode.unpaid:
        setPayMode('unpaid');
        break;
    }
  }

  void setPayMode(String _paymentMode) {
    setState(() {
      paymentMode = _paymentMode;
    });
  }

  static String getDate(String fullDate) {
    String date = fullDate.split(' ')[0];

    var dateList = date.split('-');
    date = "${dateList[0]}/${dateList[1]}/${dateList[2]}";

    return date;
  }
  
  @override
  Widget build(BuildContext context) {
    String symbolType = data["settings"]["symbol_type"];
    String currencyCode = data["settings"]["currency"];
    Map<String, dynamic> currency = currencyList[currencyCode];

    return Scaffold(
      appBar: AppBar(
        title: () {
          if (editMode)
            return Text("Edit Record");
          else
            return Text("Add Record");
        }(),
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: "Submit",
        child: Icon(Icons.done_outline),
        onPressed: () {
          setPayData();
          print(newRecord);

          Map<String, String> oldRecord;
          int oldIndex;

          if (! editMode) {
            if (! data["records"].containsKey(dateStr)) {
              data["records"][dateStr] = [newRecord];
            }
            else {
              data["records"][dateStr].add(newRecord);
            }

            dataKeys = getSortedDataKeys();
          }
          else {
            int index = indexOfRecord(List<Map>.from(data["records"][_oldDate]), editRecordData);
            print(data);

            oldIndex = index;
            print("oldIndex: $oldIndex; newDate: $dateStr; oldDate: $_oldDate");
            oldRecord = Map<String, String>.from(data["records"][_oldDate][index]);

            if (_oldDate != dateStr) {
              // _oldDate -> OLD
              // dateStr -> NEW
              
              // Add Record
              if (! data["records"].containsKey(dateStr)) {
                data["records"][dateStr] = [newRecord];
              }
              else {
                data["records"][dateStr].add(newRecord);
              }
              print(index);
              
              // Remove Old Record
              data["records"][_oldDate].removeAt(index);

              if (data["records"][_oldDate].isEmpty) {
                data["records"].remove(_oldDate);
              }
              
              dataKeys = getSortedDataKeys();
            }
            else {
              // Edit the same Record
              data["records"][_oldDate][index] = newRecord;
            }
          }
          
          saveData();

          if (editMode) {
            var details = {
              "oldRecord": oldRecord,
              "newRecord": newRecord,
              "oldDate": _oldDate,
              "newDate": dateStr,
              "oldIndex": oldIndex,
              "newIndex": data["records"][dateStr].indexOf(newRecord),
            };

            print(details);

            Navigator.of(context).pop(details);
          }
          else {
            Navigator.of(context).pop();
          }
        },
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: getGradient(paymentMode)
        ),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: 50.0
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.0
              ),
              child: RawMaterialButton(
                onPressed: () {_pickPaymentMode(context);},
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(getPaymentIcon(paymentMode),
                      size: 80.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 20.0
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        (paymentMode != "unpaid")
                          ? Icon(Icons.verified_user,
                            size: 16.0,
                          )
                          : Icon(Icons.error,
                            size: 16.0,
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 8.0
                          ),
                        ),
                        Text("Payment Mode:"),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10.0
                      ),
                    ),
                    Text(expandPaymentMode(paymentMode),
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                    ),
                  ]
                ),
                textStyle: TextStyle(
                  color: Colors.white
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                  )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 50.0
              ),
            ),
            Container(
              decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)
                )
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 20.0
              ),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Item Name",
                      labelStyle: TextStyle(fontSize: 18.0),
                      contentPadding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(20, 0, 0, 0),
                      prefixIcon: Icon(Icons.local_offer),
                    ),
                    onChanged: (string) {
                      itemName = string;
                    },
                    controller: _itemNameController,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 25.0
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Amount",
                      labelStyle: TextStyle(fontSize: 18.0),
                      contentPadding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(20, 0, 0, 0),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: "${currency[symbolType]} ",
                    ),
                    onChanged: (string) {
                      itemPrice = string;
                    },
                    controller: _itemPriceController,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black
                    ),
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 25.0
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Note",
                      labelStyle: TextStyle(fontSize: 18.0),
                      contentPadding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 18.0
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(20, 0, 0, 0),
                      prefixIcon: Icon(Icons.note),
                    ),
                    onChanged: (string) {
                      note = string;
                    },
                    controller: _noteController,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 25.0
                    ),
                  ),
                  FlatButton(
                    color: Color.fromARGB(20, 0, 0, 0),
                    onPressed: () {_pickDate(context);},
                    padding: EdgeInsets.only(
                      left: 0.0,
                      top: 10.0,
                      bottom: 10.0
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 10.0,
                          ),
                        ),
                        Icon(Icons.event,
                          color: Colors.indigo,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 15.0,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Date",
                              style: TextStyle(
                                color: Colors.indigo
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5.0
                              ),
                            ),
                            Text("${weekday(dateStr).substring(0, 3)}, ${getFullDate(dateStr)}",
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ]
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 15.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 50.0
                    ),
                  ),
                ],
              )
            )
          ]
        )
      ),
    );
  }
}