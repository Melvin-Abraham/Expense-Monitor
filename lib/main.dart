import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';

void main() => runApp(
  new MaterialApp(
    title: "Expense Monitor",
    home: new MyApp(),
    theme: new ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'ProductSans',
    ),
    routes: <String, WidgetBuilder> {
      "/AddRecord": (BuildContext context) => new AddRecord(),
    },
    debugShowCheckedModeBanner: false,
  )
);

// var data = {
//   "01/01/2018": [
//     ["CocaCola", "\$ 5", 'cash'],
//     ["Dominos Pizza", "\$ 50", 'e_wallet'],
//   ],

//   "04/01/2018": [
//     ["Appy Fizz", "\$ 10", 'cash'],
//     ["Galaxy S9+", "\$ 700", 'c_card'],
//     ["Apple iPhone X", "\$ 999", 'online'],
//   ],
// };

var data = {};
List<dynamic> dataKeys = [];

// String dataPath = "/storage/emulated/0/expense_data/data.json";

List<dynamic> _updateDataKeys() {
  var keyList = [];

  keyList = data.keys.toList();
  keyList.sort();
  // keyList.sort((a, b) => a.split('/')[1].compareTo(b.split('/')[1]));
  // keyList.sort((a, b) => a.split('/')[0].compareTo(b.split('/')[0]));
  keyList = keyList.reversed.toList();

  return keyList;
}

String getFullDate(String date) {
  List<String> dateSplit = date.split('/');
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"];

  return "${dateSplit[2]} ${months[int.parse(dateSplit[1]) - 1]} ${dateSplit[0]}";
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

  return Icons.money_off;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  String path = await _localPath;
  return new File("$path/data.json");
}

Future<Null> saveData() async {
  File dataFile = await _localFile;
  String dataString = json.encode(data);
  dataFile.writeAsString(dataString);
}

LinearGradient _getGradient(String paymentMode) {
  if (paymentMode == 'cash') {
    return new LinearGradient(
      colors: [
        Colors.orangeAccent,
        Colors.deepOrange,
      ]
    );
  }
  else if (paymentMode == 'e_wallet') {
    return new LinearGradient(
      colors: [
        Colors.green,
        Colors.lime,
      ]
    );
  }
  else if (paymentMode == 'online') {
    return new LinearGradient(
      colors: [
        Colors.purpleAccent,
        Colors.deepPurple,
      ]
    );
  }
  else if (paymentMode == 'c_card') {
    return new LinearGradient(
      colors: [
        Colors.teal,
        Colors.blueGrey,
      ]
    );
  }
  else if (paymentMode == 'd_card') {
    return new LinearGradient(
      colors: [
        Colors.pink,
        Colors.redAccent,
      ]
    );
  }

  return new LinearGradient(
    colors: [
      Colors.black,
      Colors.white,
    ]
  );
}

String _payModeString(String paymentMode) {
    if (paymentMode == 'cash') {
      return "Cash";
    }
    else if (paymentMode == 'e_wallet') {
      return "E-Wallet";
    }
    else if (paymentMode == 'online') {
      return "Online Banking";
    }
    else if (paymentMode == 'c_card') {
      return "Credit Card";
    }
    else if (paymentMode == 'd_card') {
      return "Debit Card";
    }

    return "None";
  }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;
  
  _MyAppState() {
    getData();
    dataKeys = _updateDataKeys();
  }

  // void _showSnackBar() {
  //   var snackbar = new SnackBar(
  //     content: new Text("Loading..."),
  //     duration: new Duration(minutes: 2),
  //   );

  //   Scaffold.of(context).showSnackBar(snackbar);
  // }

  // void _hideSnackBar() {
  //   Scaffold.of(context).hideCurrentSnackBar();
  // }

  Future<Null> getData() async {
    File dataFile = await _localFile;

    try {
      String contents = await dataFile.readAsString();
      data = json.decode(contents);
      print("data: $data");
      dataKeys = _updateDataKeys();
    }
    catch(e) {
      print(e);
      saveData();
    }

    setState(() {
      loading = false;
    });
  }

  static Future<Null> vibrate() async {
    await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
  }

  List<Widget> _buildList(int keyIndex, Key key) {
    List<Widget> list = [];

    for (int i = 0; i < data[dataKeys[keyIndex]].length; i++) {
      list.add(
        new GestureDetector(
          onLongPress: () {
            vibrate();
            _showModal(key, data[dataKeys[keyIndex]][i], dataKeys[keyIndex]);
          },
          child: new Card(
            color: Colors.transparent,
            elevation: 4.0,
            child: new Container(
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(
                  10.0
                ),
                gradient: _getGradient(data[dataKeys[keyIndex]][i][2])
              ),
              padding: new EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.only(
                      left: 10.0
                    ),
                  ),
                  new CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: new Icon(getPaymentIcon(data[dataKeys[keyIndex]][i][2]),
                      color: Colors.white,
                      size: 27.0,
                    ),
                    radius: 25.0,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                      bottom: 10.0,
                      right: 20.0
                    ),
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text("${data[dataKeys[keyIndex]][i][0]}",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                            color: Colors.white,
                          )
                      ),
                      new Padding(
                        padding:
                            new EdgeInsets.symmetric(vertical: 3.0),
                      ),
                      new Text("₹ ${data[dataKeys[keyIndex]][i][1]}",
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                      // new Padding(
                      //   padding:
                      //       new EdgeInsets.symmetric(vertical: 7.0),
                      // ),
                      // new Container(
                      //   color: Colors.white,
                      //   height: 3.0,
                      //   width: 50.0,
                      // ),
                      new Padding(
                        padding:
                            new EdgeInsets.symmetric(vertical: 6.0),
                      ),
                      new Row(
                        children: <Widget>[
                          new Icon(Icons.verified_user,
                            color: Colors.white70,
                            size: 15.0,
                          ),
                          new Padding(
                            padding:
                                new EdgeInsets.only(right: 5.0),
                          ),
                          new Text(_payModeString(data[dataKeys[keyIndex]][i][2]),
                            style: new TextStyle(
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
          )
        )
      );
    }

    return list;
  }

  Widget renderHome(Key key) {
    if (dataKeys.length != 0) {
      return new Container (
        child: new ListView.builder(
          itemCount: dataKeys.length,
          itemBuilder: (BuildContext context, int keyIndex) {
            return new ExpansionTile(
              initiallyExpanded: true,
              title: new Text(getFullDate(dataKeys[keyIndex])),
              children: <Widget>[
                new Column(
                  children: _buildList(keyIndex, key)
                )
              ]
            );
          }
        )
      );
    }
    else {
      return new Container(
        padding: new EdgeInsets.only(
          top: 40.0
        ),
        child: new Center(
          heightFactor: 1.5,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.only(
                  top: 30.0
                ),
              ),
              new Icon(Icons.cancel,
                size: 70.0,
                color: Colors.redAccent,
              ),
              new Padding(
                padding: new EdgeInsets.only(
                  top: 15.0
                ),
              ),
              new Center(
                child: new Text("You have no expense records till now!",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                )
              ),
              new Padding(
                padding: new EdgeInsets.only(
                  top: 40.0
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showModal(Key key, List<dynamic> record, String date) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return new Container(
          padding: new EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new FlatButton(
                padding: new EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0
                ),
                onPressed: () {
                  int index = _removeRecord(context, record, date);
                  saveData();

                  // SnackBar snackbar = new SnackBar(
                  //   content: new Text("Deleted '${record[0]}'"),
                  //   action: new SnackBarAction(
                  //     label: "Undo",
                  //     onPressed: () {
                  //       if (data.containsKey(date)) {
                  //         data[date].insert(index, record);
                  //       }
                  //       else {
                  //         data[date] = [record];

                  //         setState(() {
                  //           dataKeys = _updateDataKeys();           
                  //         });
                  //       }
                  //     },
                  //   ),
                  // );
                  
                  Navigator.of(context).pop();
                },
                child: new Row(
                  children: <Widget>[
                    new Icon(Icons.delete,
                      size: 30.0,
                      color: Colors.black45,
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(
                        right: 30.0
                      )
                    ),
                    new Text("Delete",
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400
                      )
                    ),
                  ],
                ),
              ),
              new FlatButton(
                padding: new EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _editRecordData = record;
                  _editDate = date;
                  _editRecord(context);
                },
                child: new Row(
                  children: <Widget>[
                    new Icon(Icons.edit,
                      size: 30.0,
                      color: Colors.black45,
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(
                        right: 30.0
                      )
                    ),
                    new Text("Edit",
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  int _removeRecord(BuildContext context, List<dynamic> record, String date) {
    int index = data[date].indexOf(record);
    print(index);

    data[date].removeAt(index);
    print(data[date]);

    if (data[date].isEmpty) {
      data.remove(date);
    }

    setState(() {
      dataKeys = _updateDataKeys();
      print(data);
    });

    return index;
  }

  void _editRecord(BuildContext context) {
    editMode = true;
    Navigator.of(context).pushNamed("/AddRecord");
  }
  
  @override
  Widget build(BuildContext context) {
    if (!loading) {
      final key = new GlobalKey<ScaffoldState>();

      return new Scaffold(
        key: key,
        appBar: new AppBar(
          backgroundColor: Colors.white,
          title: new Text("Expense Monitor",
            style: new TextStyle(
              color: Colors.indigo
            )
          ),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.search,
                color: Colors.black54
              ),
              tooltip: "Search",
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
                
                // SnackBar snackbar = new SnackBar(
                //   content: new Text("Search feature not implemented yet!"),
                // );

                // key.currentState.showSnackBar(snackbar);
              },
            ),
            new PopupMenuButton(
              icon: new Icon(Icons.more_vert,
                color: Colors.black54
              ),
              onSelected: (option) {
                if (option == 'export') {
                  print('Export');

                  Future<Null> exportData() async {
                    String fullpath = '/sdcard/expense_monitor/backup/backup.json';
                    File dataFile = await new File(fullpath).create(recursive: true);
                    
                    String dataString = json.encode(data);
                    dataFile.writeAsString(dataString);
                    // To be implemented with SNACKBAR.

                    SnackBar snackbar = new SnackBar(
                      content: new Text("Data Exported successfully!"),
                    );

                    key.currentState.showSnackBar(snackbar);
                  }
                  
                  () async {
                    bool checkPermission = await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
                    print(checkPermission);

                    if (checkPermission) {
                      print('Has Write to External Storage Permission...');
                      exportData();
                    }
                    else {
                      final res = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

                      if (res == PermissionStatus.authorized) {
                        print('Got Permission');
                        exportData();
                      }

                      else {
                        print('Denied Permission.');

                        SnackBar snackbar = new SnackBar(
                          content: new Text("Permission Denied!"),
                        );

                        key.currentState.showSnackBar(snackbar);
                      }
                    }
                  }();
                }
                else if (option == 'import') {
                  print('Import');
                  SnackBar snackbar;

                  Future<Null> importData() async {
                    try {
                      String fullpath = '/sdcard/expense_monitor/backup/backup.json';
                      File dataFile = new File(fullpath);
                      
                      String contents = await dataFile.readAsString();
                      data = json.decode(contents);

                      saveData();

                      setState(() {
                        dataKeys = _updateDataKeys();

                        snackbar = new SnackBar(
                          content: new Text("Data Imported successfully!"),
                        );

                        key.currentState.showSnackBar(snackbar);
                      });
                    }
                    catch (FileSystemException) {
                      snackbar = new SnackBar(
                        content: new Text("No Backup found!"),
                      );

                      key.currentState.showSnackBar(snackbar);
                    }
                  }
                  
                  () async {
                    bool checkPermission = await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
                    print(checkPermission);

                    if (checkPermission) {
                      print('Has Read to External Storage Permission...');
                      importData();
                    }
                    else {
                      final res = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

                      if (res == PermissionStatus.authorized) {
                        print('Got Permission');
                        importData();
                      }

                      else {
                        print('Denied Permission.');

                        SnackBar snackbar = new SnackBar(
                          content: new Text("Permission Denied!"),
                        );

                        key.currentState.showSnackBar(snackbar);
                      }
                    }
                  }();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                new PopupMenuItem(
                  value: 'export',
                  child: new Container(
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.file_upload,
                          color: Colors.black54,
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(
                            right: 10.0
                          ),
                        ),
                        new Text('Export')
                      ],
                    )
                  )
                ),
                new PopupMenuItem(
                  value: 'import',
                  child: new Container(
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.file_download,
                          color: Colors.black54,
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(
                            right: 10.0
                          ),
                        ),
                        new Text('Import')
                      ],
                    )
                  )
                ),
              ]
            )
          ],
        ),
        body: renderHome(key),
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          tooltip: "Add Item",
          onPressed: () {
            editMode = false;
            Navigator.of(context).pushNamed("/AddRecord");
          },
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
    else {
      return Scaffold(
        body: new Container(
          child: new Center(
            child: new CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}

enum Filter {
  name,
  price,
  paymode
}

class CustomSearchDelegate extends SearchDelegate<String>{
  int _filter = 0;
  
  @override
    Widget buildLeading(BuildContext context) {
      // TODO: implement buildLeading
      return new IconButton(
        tooltip: "Back",
        icon: new AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        },
      );
    }

  @override
    List<Widget> buildActions(BuildContext context) {
      // TODO: implement buildActions
      return <Widget>[
        IconButton(
          tooltip: "Filter",
          icon: new Icon(Icons.filter_list),
          onPressed: () {
            () async {
              var dialog = await showDialog(
                context: context,
                builder: (context) {
                  return new SimpleDialog(
                    title: new Text("Filter By",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: <Widget>[
                      new SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.name); },
                        child: new Row(
                          children: <Widget>[
                            new Icon(Icons.edit),
                            new Padding(
                              padding: new EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            new Text("Item Name",
                              style: new TextStyle(
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      new SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.price); },
                        child: new Row(
                          children: <Widget>[
                            new Icon(Icons.attach_money),
                            new Padding(
                              padding: new EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            new Text("Price",
                              style: new TextStyle(
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      new SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.paymode); },
                        child: new Row(
                          children: <Widget>[
                            new Icon(Icons.verified_user),
                            new Padding(
                              padding: new EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            new Text("Payment Mode",
                              style: new TextStyle(
                                fontSize: 15.0,
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
                case Filter.name:
                  _filter = 0;
                  showSuggestions(context);
                  break;
                case Filter.price:
                  _filter = 1;
                  showSuggestions(context);
                  break;
                case Filter.paymode:
                  _filter = 2;
                  showSuggestions(context);
                  break;
              }
            }();
          },
        )
      ];
    }

  @override
    Widget buildSuggestions(BuildContext context) {
      // TODO: implement buildSuggestions

      List<Widget> _suggestion = [];

      _suggestion.add(
        new ListTile(
          leading: new Icon(Icons.filter_list),
          title: new Text("Filtering by: '${_filter == 0 ? 'Item Name' : _filter == 1 ? 'Price' : 'Payment Mode'}'",
            style: new TextStyle(color: Colors.black45)
          ),
        )
      );

      if (_filter == 2) {
        //
      }

      return new Column(
        children: _suggestion,
      );
    }

  @override
    Widget buildResults(BuildContext context) {
      Map<String, List<List<dynamic>>> results = {};
      List<Widget> resultsUI = [];

      for (String key in data.keys) {
        for (List<dynamic> itemList in data[key]) {
          if (itemList[_filter].toLowerCase().contains(query.toLowerCase())) {
            if (results.containsKey(key)) {
              results[key].add(itemList);
            }
            else {
              results[key] = [itemList];
              resultsUI.add(
                new ListTile(
                  title: new Text(getFullDate(key),
                    style: new TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                )
              );
            }

            resultsUI.add(
              new Card(
                color: Colors.transparent,
                elevation: 4.0,
                child: new Container(
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(
                      10.0
                    ),
                    gradient: _getGradient(itemList[2])
                  ),
                  padding: new EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 10.0
                        ),
                      ),
                      new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: new Icon(getPaymentIcon(itemList[2]),
                          color: Colors.white,
                          size: 27.0,
                        ),
                        radius: 25.0,
                      ),
                      new Padding(
                        padding: new EdgeInsets.only(
                          bottom: 10.0,
                          right: 20.0
                        ),
                      ),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("${itemList[0]}",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.white,
                              )
                          ),
                          new Padding(
                            padding:
                                new EdgeInsets.symmetric(vertical: 3.0),
                          ),
                          new Text("₹ ${itemList[1]}",
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                          new Padding(
                            padding:
                                new EdgeInsets.symmetric(vertical: 6.0),
                          ),
                          new Row(
                            children: <Widget>[
                              new Icon(Icons.verified_user,
                                color: Colors.white70,
                                size: 15.0,
                              ),
                              new Padding(
                                padding:
                                    new EdgeInsets.only(right: 5.0),
                              ),
                              new Text(_payModeString(itemList[2]),
                                style: new TextStyle(
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
              )
            );
          }
        }
      }

      if (results.isEmpty) {
        resultsUI.add(
          new Container(
            alignment: Alignment.center,
            child: new ListTile(
              leading: new Icon(Icons.sentiment_dissatisfied,
                color: Colors.black54,
              ),
              title: new Container(
                // alignment: Alignment.center,
                child: new Text("No matching results..."),
              ),
            )
          )
        );
      }

      resultsUI.insert(0, 
        new ListTile(
          leading: new Icon(Icons.filter_list),
          title: new Text("Filtered by '${_filter == 0 ? 'Item Name' : _filter == 1 ? 'Price' : 'Payment Mode'}'",
            style: new TextStyle(
              color: Colors.black45
            )
          ),
        )
      );
      
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, _) {
          return Column(
            children: resultsUI,
          );
        },
      );
    }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return new ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: new RichText(
            text: new TextSpan(
              text: suggestion.substring(0, query.length),
              style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                new TextSpan(
                  text: suggestion.substring(query.length),
                  style: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}

List<dynamic> _editRecordData = [];
String _editDate = "";
bool editMode = false;

enum PayMode {
  cash,
  e_wallet,
  online,
  c_card,
  d_card,
}

class AddRecord extends StatefulWidget {
  @override
  _AddRecordState createState() => new _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  static DateTime _date = new DateTime.now();
  String _dateStr = getDate(_date.toString());
  String itemName = '';
  String itemPrice = '';
  String _paymentMode = 'cash';
  List<String> paymentData = [];
  TextEditingController _itemNameController;
  TextEditingController _itemPriceController;

  _AddRecordState() {
    if (editMode) {
      itemName = _editRecordData[0];
      itemPrice = _editRecordData[1];
      _paymentMode = _editRecordData[2];

      _dateStr = _editDate;
      _date = new DateTime(
        int.parse(_dateStr.split('/')[0]),
        int.parse(_dateStr.split('/')[1]),
        int.parse(_dateStr.split('/')[2]),
      );
    }

    _itemNameController = 
      new TextEditingController(
        text: itemName,
      );
      
    _itemPriceController = 
      new TextEditingController(
        text: itemPrice,
      );
  }

  void setPayData() {
    paymentData = [itemName, itemPrice, _paymentMode];
  }
  
  Future<Null> _pickDate(BuildContext context) async { 
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(2000),
      lastDate: new DateTime(3000)
    );

    if (picked != null) {
      _date = picked;
      String datePicked = picked.toString();
      
      setState(() {
        _dateStr = getDate(datePicked);
      });
    }
  }

  Future<Null> _pickMode(BuildContext context) async {
    var dialog = await showDialog(
      context: context,
      builder: (context) {
        return new SimpleDialog(
          title: new Text("Select Payment Mode",
            style: new TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: <Widget>[
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.cash); },
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.monetization_on),
                  new Padding(
                    padding: new EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  new Text("Cash",
                    style: new TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.e_wallet); },
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.account_balance_wallet),
                  new Padding(
                    padding: new EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  new Text("E-wallet",
                    style: new TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.online); },
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.vpn_lock),
                  new Padding(
                    padding: new EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  new Text("Online Banking",
                    style: new TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.c_card); },
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.credit_card),
                  new Padding(
                    padding: new EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  new Text("Credit Card",
                    style: new TextStyle(
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, PayMode.d_card); },
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.card_membership),
                  new Padding(
                    padding: new EdgeInsets.only(
                      right: 10.0
                    ),
                  ),
                  new Text("Debit Card",
                    style: new TextStyle(
                      fontSize: 15.0,
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
    }
  }

  void setPayMode(String paymentMode) {
    setState(() {
      _paymentMode = paymentMode;
    });
  }

  static String getDate(String fullDate) {
    String date = fullDate.split(' ')[0];

    var dateList = date.split('-');
    date = "${dateList[0]}/${dateList[1]}/${dateList[2]}";

    return date;
  }

  // List<dynamic> _record = [];
  // String _dateString = "";

  // bool editMode = false;

  // @override
  // void initState([List<dynamic> record = const [], String dateStr = ""]) {
  //   // TODO: implement initState
  //   _record = record;
  //   _dateString = dateStr;

  //   if (_record.isNotEmpty && _dateString != "") {
  //     editMode = true;
  //   }
    
  //   super.initState();
  // }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: () {
          if (editMode)
            return new Text("Edit Record");
          else
            return new Text("Add Record");
        }(),
      ),
      body: new Container(
        child: new ListView.builder(
          itemCount: 1,
          itemBuilder: (context, _) {
            return new Container(
              padding: new EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 20.0
              ),
              child: new Column(
                children: <Widget>[
                  new RawMaterialButton(
                    onPressed: () {_pickMode(context);},
                    padding: new EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0
                    ),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Icon(getPaymentIcon(_paymentMode),
                          size: 80.0,
                        ),
                      ]
                    ),
                    textStyle: new TextStyle(
                      color: Colors.white
                    ),
                    fillColor: Colors.orangeAccent,
                    shape: const StadiumBorder(),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                      bottom: 50.0
                    ),
                  ),
                  new TextField(
                    decoration: new InputDecoration(
                      labelText: "Item Name",
                      labelStyle: new TextStyle(fontSize: 18.0),
                      icon: new Icon(Icons.edit),
                      contentPadding: new EdgeInsets.only(
                        bottom: 2.0
                      ),
                    ),
                    onChanged: (string) {
                      itemName = string;
                    },
                    controller: _itemNameController,
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.black
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                      bottom: 25.0
                    ),
                  ),
                  new TextField(
                    decoration: new InputDecoration(
                      labelText: "Amount",
                      labelStyle: new TextStyle(fontSize: 18.0),
                      icon: new Icon(Icons.attach_money),
                      contentPadding: new EdgeInsets.only(
                        bottom: 2.0
                      ),
                    ),
                    controller: _itemPriceController,
                    onChanged: (string) {
                      itemPrice = string;
                    },
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.black
                    ),
                    keyboardType: new TextInputType.numberWithOptions(),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                      bottom: 25.0
                    ),
                  ),
                  new FlatButton(
                    onPressed: () {_pickDate(context);},
                    padding: new EdgeInsets.only(
                      left: 0.0,
                      top: 10.0,
                      bottom: 10.0
                    ),
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.event),
                        new Padding(
                          padding: new EdgeInsets.only(
                            right: 15.0,
                          ),
                        ),
                        new Text(getFullDate(_dateStr),
                          style: new TextStyle(
                            fontSize: 18.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                      bottom: 50.0
                    ),
                  ),
                  new RawMaterialButton(
                    onPressed: () {
                      setPayData();
                      print(paymentData);

                      if (! editMode) {
                        if (! data.containsKey(_dateStr)) {
                          data[_dateStr] = [paymentData];
                        }
                        else {
                          data[_dateStr].add(paymentData);
                        }

                        dataKeys = _updateDataKeys();
                      }
                      else {
                        int index = data[_editDate].indexOf(_editRecordData);
                        print(data);
                        
                        if (_editDate != _dateStr) {
                          // _editDate -> OLD
                          // _dateStr -> NEW
                          
                          // Add New Record
                          if (! data.containsKey(_dateStr)) {
                            data[_dateStr] = [paymentData];
                          }
                          else {
                            data[_dateStr].add(paymentData);
                          }
                          print(index);
                          
                          // Remove Old Record
                          data[_editDate].removeAt(index);

                          if (data[_editDate].isEmpty) {
                            data.remove(_editDate);
                          }
                          
                          dataKeys = _updateDataKeys();
                        }
                        else {
                          // Edit the same Record
                          data[_editDate][index] = paymentData;
                        }
                      }

                      // _itemNameController.dispose();
                      // _itemPriceController.dispose();
                      
                      saveData();
                      Navigator.of(context).pop();
                    },
                    padding: new EdgeInsets.symmetric(
                      vertical: 13.0
                    ),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon(Icons.done),
                        new Padding(
                          padding: new EdgeInsets.only(
                            right: 10.0
                          )
                        ),
                        new Text("SUBMIT")
                      ],
                    ),
                    textStyle: new TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: Colors.blueAccent,
                    shape: const StadiumBorder(),
                  )
                ],
              )
            );
          }
        ),
      ),
    );
  }
}
