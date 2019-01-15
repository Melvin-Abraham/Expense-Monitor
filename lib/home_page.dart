import 'package:expense_monitor/add_record_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';

import './main.dart';
import './appbar.dart';
import './func_lib.dart';
import './settings_page.dart';
import './record_detail_page.dart';

class MyApp extends StatefulWidget {
  MyApp({Key key}): super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int loadingCounter = 2;
  final PageStorageBucket bucket = PageStorageBucket();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  @override
  void initState() {
    super.initState();
    getData();
    dataKeys = getSortedDataKeys();

    () async {
      String currencyFileString = await rootBundle.loadString("assets/json/currency_list.json");
      currencyList = json.decode(currencyFileString);
      
      setState(() {
        loadingCounter--;
        print("==================  Assets Loaded ::counter = $loadingCounter");
      });

      packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;

      if (await googleSignIn.isSignedIn()) {
        if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
          bool signedIn = await handleSignIn(auth);

          SnackBar snackbar = _getSignInSnackbar(signedIn);          
          Scaffold.of(context).showSnackBar(snackbar);
        }
        else {
          SnackBar snackbar = SnackBar(
            content: Text("No internet! You will be automatically signed in after connection is regained..."),
          );

          Scaffold.of(context).showSnackBar(snackbar);
          
          _connectivitySubscription =
              _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
            setState(() {
              () async {
                if (result != ConnectivityResult.none) {
                  var signedIn = await handleSignIn(auth);

                  SnackBar snackbar = _getSignInSnackbar(signedIn);
                  Scaffold.of(context).showSnackBar(snackbar);

                  if (signedIn) {
                    print("Connectivity Subscription was cancelled!");
                    _connectivitySubscription.cancel();
                  }
                }
              }();
            });
          });
        }
      }
    }();
  }

  Future<Null> getData() async {
    File dataFile = await localFile;

    try {
      String contents = await dataFile.readAsString();
      Map<String, dynamic> record = json.decode(contents);
      handleData(record);
      print("data: $data");
      dataKeys = getSortedDataKeys();
    }
    catch(e) {
      print(e);
      saveData();
    }

    setState(() {
      loadingCounter--;
      print("==================  Local Data Loaded ::counter = $loadingCounter");
    });
  }

  SnackBar _getSignInSnackbar(bool signedIn) {
    if (signedIn) {
      return SnackBar(
        content: Text("Successfully signed in ${user.displayName}!"),
      );
    }

    return SnackBar(
      content: Text("Unexpected error occured while signing in!"),
    );
  }

  List<Widget> buildSliverContents() {
    List<Widget> widgets = [];

    for (int index = 0; index < dataKeys.length; index++) {
      String dateStr = dataKeys[index];

      widgets.add(
        SliverStickyHeaderBuilder(
          builder: (context, state) => Container(
            padding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(1.0 - state.scrollPercentage),
              image: DecorationImage(
                image: AssetImage("assets/material_light.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop)
              ),
            ),
            child: Text("${getFullDate(dateStr)}  (${weekday(dateStr)})",
              style: TextStyle(
                color: Colors.blue.withOpacity(1.0 - state.scrollPercentage),
                fontSize: 16.0
              ),
            ),
          ),
        
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) => GestureDetector(
                onLongPress: () {
                  vibrate();
                  showModal(getRecord(data, dataKeys[index], i), dataKeys[index]);
                },
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => RecordDetailPage(dataKeys[index], i)
                  ));
                },
                child: buildCard(data, dataKeys[index], i, sortedDataKeys: dataKeys),
              ),
              
              childCount: data["records"][dataKeys[index]].length
            )
          )
        )
      );
    }

    return widgets;
  }

  Widget customAppBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: MySliverPersistenceHeaderDelegate(
        title: "Expense Monitor",
        titleColor: Colors.white,
        titleSizeExpanded: 30.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search,
              color: Colors.white,
            ),
            tooltip: "Search",
            onPressed: () {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white,
                statusBarBrightness: Brightness.dark,
              ));
              
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert,
              color: Colors.white
            ),
            onSelected: (option) {
              if (option == 'export') {
                print('Export');

                Future<Null> exportData() async {
                  String fullpath = '/sdcard/expense_monitor/backup/backup.json';
                  File dataFile = await File(fullpath).create(recursive: true);
                  
                  String dataString = json.encode(data);
                  dataFile.writeAsString(dataString);

                  SnackBar snackbar = SnackBar(
                    content: Text("Data Exported successfully!"),
                  );

                  Scaffold.of(context).showSnackBar(snackbar);
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

                      SnackBar snackbar = SnackBar(
                        content: Text("Permission Denied!"),
                      );

                      Scaffold.of(context).showSnackBar(snackbar);
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
                    File dataFile = File(fullpath);
                    
                    String contents = await dataFile.readAsString();
                    Map<String, dynamic> record = json.decode(contents);

                    handleData(record);
                    saveData();

                    setState(() {
                      dataKeys = getSortedDataKeys();

                      snackbar = SnackBar(
                        content: Text("Data Imported successfully!"),
                      );

                      Scaffold.of(context).showSnackBar(snackbar);
                    });
                  }
                  catch (FileSystemException) {
                    snackbar = SnackBar(
                      content: Text("No Backup found!"),
                    );

                    Scaffold.of(context).showSnackBar(snackbar);
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

                      SnackBar snackbar = SnackBar(
                        content: Text("Permission Denied!"),
                      );

                      Scaffold.of(context).showSnackBar(snackbar);
                    }
                  }
                }();
              }

              else if (option == "settings") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Settings();
                    }
                  )
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: 'export',
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.file_upload,
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10.0
                        ),
                      ),
                      Text('Export')
                    ],
                  )
                )
              ),
              PopupMenuItem(
                value: 'import',
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.file_download,
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10.0
                        ),
                      ),
                      Text('Import')
                    ],
                  )
                )
              ),
              PopupMenuItem(
                value: 'settings',
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.settings,
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10.0
                        ),
                      ),
                      Text('Settings')
                    ],
                  )
                )
              ),
            ]
          )
        ],
      ),
    );
  }

  Widget renderHome() {    
    if (dataKeys.length != 0) {
      var _scrollController = ScrollController(
        keepScrollOffset: true
      );

      final pagestorage = PageStorageKey('renderHome::key');
      
      return SafeArea(
        top: true,
        child: Container (
          child: CustomScrollView(
            key: pagestorage,
            controller: _scrollController,
            slivers: () {
              List<Widget> widgets = buildSliverContents();
              widgets.insert(0, customAppBar());

              return widgets;
            }()
          )
        ),
      );
    }
    else {
      return SafeArea(
        top: true,
        child: Container(
          child: CustomScrollView(
            slivers: <Widget>[
              customAppBar(),

              SliverFillRemaining(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 90.0,
                                child: FlareActor(
                                  "assets/anim/BrokenHeart.flr",
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.center,
                                  animation: "Heart Break",
                                  shouldClip: false,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 20.0
                                ),
                              ),
                              Text("Nothing to show...",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 16.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 15.0
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("You have no expense records till now!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ]
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 30.0
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
      );
    }
  }

  void showModal(Map<String, String> record, String date) {
    () async {
      Widget snackbar = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0
                  ),
                  onPressed: () {
                    int index = _removeRecord(context, record, date);
                    saveData();

                    SnackBar snackbar = SnackBar(
                      content: Text("Deleted \"${record["name"]}\" (${getFullDate(date)}, ${weekday(date)})"),
                      action: SnackBarAction(
                        label: "Undo",
                        textColor: Colors.blue,
                        onPressed: () {
                          if (data["records"].containsKey(date)) {
                            data["records"][date].insert(index, record);
                          }
                          else {
                            data["records"][date] = [record];

                            setState(() {
                              dataKeys = getSortedDataKeys();
                            });
                          }

                          setState(() {});    // Rebuild the interface after a data deletion is "Undone"...
                          saveData();
                        },
                      ),
                    );
                    
                    Navigator.of(context).pop(snackbar);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete,
                        size: 30.0,
                        color: Colors.black45,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 30.0
                        )
                      ),
                      Text("Delete",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400
                        )
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0
                  ),
                  onPressed: () {
                    // Edit-Record SNACKBAR
                    SnackBar snackbar;

                    () async {
                      Map<String, dynamic> edits = await editRecord(context, record, date);
                      
                      if (edits == null || (isIdenticalRecord(edits["oldRecord"], edits["newRecord"]) && edits["oldDate"] == edits["newDate"])) {
                        Navigator.of(context).pop();
                        return;
                      }

                      snackbar = SnackBar(
                        content: () {
                          if (edits["oldRecord"]["name"] != edits["newRecord"]["name"]) {
                            return Text("Edited:\n\"${edits["oldRecord"]["name"]}\" to \"${edits["newRecord"]["name"]}\"");
                          }

                          else if (edits["oldRecord"]["amount"] != edits["newRecord"]["amount"]) {
                            return Text("Edited: \"${edits["oldRecord"]["name"]}\"\nAmount from ${(edits["oldRecord"]["amount"] != "") ? edits["oldRecord"]["amount"] : 0} to ${(edits["newRecord"]["amount"] != "") ? edits["newRecord"]["amount"] : 0}");
                          }

                          else if (edits["oldRecord"]["payMode"] != edits["newRecord"]["payMode"]) {
                            return Text("Edited: \"${edits["oldRecord"]["name"]}\"\nFrom `${expandPaymentMode(edits["oldRecord"]["payMode"])}` to `${expandPaymentMode(edits["newRecord"]["payMode"])}`");
                          }

                          else if (edits["oldDate"] != edits["newDate"]) {
                            return Text("Edited: \"${edits["oldRecord"]["name"]}\"\nFrom \"${getFullDate(edits["oldDate"])}\" to \"${getFullDate(edits["newDate"])}\"");
                          }

                          else if (edits["oldRecord"]["note"] != edits["newRecord"]["note"]) {
                            return Text("Edited: \"${edits["oldRecord"]["name"]}\"\n[NOTE CHANGED]");
                          }

                          else {
                            return Text("Edited:\n\"${edits["oldRecord"]["name"]}\"");
                          }
                        }(),
                        action: SnackBarAction(
                          label: "Undo",
                          textColor: Colors.blue,
                          onPressed: () {
                            if (edits["oldDate"] != edits["newDate"]) {
                              if (! data["records"].containsKey(edits["oldDate"])) {
                                data["records"][edits["oldDate"]] = [edits["oldRecord"]];
                              }
                              else {
                                data["records"][edits["oldDate"]].insert(edits["oldIndex"], edits["oldRecord"]);
                              }

                              data["records"][edits["newDate"]].removeAt(edits["newIndex"]);

                              if (data["records"][edits["newDate"]].isEmpty) {
                                data["records"].remove(edits["newDate"]);
                              }
                            }
                            else {
                              data["records"][edits["newDate"]][edits["newIndex"]] = edits["oldRecord"];
                            }

                            setState(() {
                              dataKeys = getSortedDataKeys();
                            });

                            saveData();
                          },
                        ),
                      );

                      Navigator.of(context).pop(snackbar);
                    }();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit,
                        size: 30.0,
                        color: Colors.black45,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 30.0
                        )
                      ),
                      Text("Edit",
                        style: TextStyle(
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

      if (snackbar != null) {
        Scaffold.of(context).showSnackBar(snackbar);
      }
    }();
  }

  int _removeRecord(BuildContext context, Map<String, String> record, String date) {
    int index = indexOfRecord(List<Map>.from(data["records"][date]), record);
    print(index);

    data["records"][date].removeAt(index);
    print(data["records"][date]);

    if (data["records"][date].isEmpty) {
      data["records"].remove(date);
    }

    setState(() {
      dataKeys = getSortedDataKeys();
      print(data);
    });

    return index;
  }

  Future<dynamic> editRecord(BuildContext context, Map<String, String> record, String date) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => AddRecord(
        editDate: date, 
        editRecordData: record
      )
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.indigoAccent,
      statusBarBrightness: Brightness.dark,
    ));
    
    if (loadingCounter == 0) {
      final key = GlobalKey<ScaffoldState>();

      return Scaffold(
        key: key,
        body: PageStorage(
          child: renderHome(),
          bucket: bucket,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Add Item",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddRecord()
            ));
          },
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
    else {
      return Scaffold(
        body: Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}

enum Filter {
  name,
  price,
  paymode,
  note
}

class CustomSearchDelegate extends SearchDelegate<String> {
  String _filter = "name";
  
  @override
    Widget buildLeading(BuildContext context) {
      return IconButton(
        tooltip: "Back",
        icon: AnimatedIcon(
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
      return <Widget>[
        IconButton(
          tooltip: "Filter",
          icon: Icon(Icons.filter_list),
          onPressed: () {
            () async {
              var dialog = await showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text("Filter By",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.name); },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.local_offer),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            Text("Item Name",
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.price); },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.attach_money),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            Text("Price",
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.paymode); },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.verified_user),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            Text("Payment Mode",
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () { Navigator.pop(context, Filter.note); },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.note),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10.0
                              ),
                            ),
                            Text("Note",
                              style: TextStyle(
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
                  _filter = "name";
                  showSuggestions(context);
                  break;

                case Filter.price:
                  _filter = "amount";
                  showSuggestions(context);
                  break;

                case Filter.paymode:
                  _filter = "payMode";
                  showSuggestions(context);
                  break;
                  
                case Filter.note:
                  _filter = "note";
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
      List<Widget> _suggestion = [];

      _suggestion.add(
        ListTile(
          leading: Icon(Icons.filter_list),
          title: Text("Filtering by: '${_filter == "name" ? 'Item Name' : _filter == "amount" ? 'Price' : _filter == "payMode" ? 'Payment Mode' : 'Note'}'",
            style: TextStyle(color: Colors.black45)
          ),
        )
      );

      if (_filter == "payMode") {
        _suggestion.addAll([
          ListTile(
            title: FlatButton(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 15.0,
                bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.monetization_on,
                    size: 28.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 25.0,
                    ),
                  ),
                  Text("Cash",
                    style: TextStyle(
                      fontSize: 17.0
                    ),
                  )
                ],
              ),
              onPressed: () => query = "cash"
            ),
          ),
          ListTile(
            title: FlatButton(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 15.0,
                bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.account_balance_wallet,
                    size: 28.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 25.0,
                    ),
                  ),
                  Text("E-Wallet",
                    style: TextStyle(
                      fontSize: 17.0
                    ),
                  )
                ],
              ),
              onPressed: () => query = "e_wallet"
            ),
          ),
          ListTile(
            title: FlatButton(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 15.0,
                bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.vpn_lock,
                    size: 28.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 25.0,
                    ),
                  ),
                  Text("Online Banking",
                    style: TextStyle(
                      fontSize: 17.0
                    ),
                  )
                ],
              ),
              onPressed: () => query = "online"
            ),
          ),
          ListTile(
            title: FlatButton(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 15.0,
                bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.credit_card,
                    size: 28.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 25.0,
                    ),
                  ),
                  Text("Credit Card",
                    style: TextStyle(
                      fontSize: 17.0
                    ),
                  )
                ],
              ),
              onPressed: () => query = "c_card"
            ),
          ),
          ListTile(
            title: FlatButton(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 15.0,
                bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.card_membership,
                    size: 28.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 25.0,
                    ),
                  ),
                  Text("Debit Card",
                    style: TextStyle(
                      fontSize: 17.0
                    ),
                  )
                ],
              ),
              onPressed: () => query = "d_card"
            ),
          ),
          ListTile(
            title: FlatButton(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 15.0,
                bottom: 15.0
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.warning,
                    size: 28.0,
                    color: Colors.redAccent,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 25.0,
                    ),
                  ),
                  Text("Unpaid",
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.redAccent
                    ),
                  )
                ],
              ),
              onPressed: () => query = "unpaid"
            ),
          ),
        ]);
      }

      return ListView(
        children: _suggestion,
      );
    }

  @override
    Widget buildResults(BuildContext context) {
      Map<String, List<Map<String, String>>> results = {};
      List<Widget> resultsUI = [];

      for (int keyIndex = 0; keyIndex < dataKeys.length; keyIndex++) {
        String date = dataKeys[keyIndex];
        
        for (int index = 0; index < data["records"][date].length; index++) {
          Map<String, String> record = Map<String, String>.from(data["records"][date][index]);
          
          if (record[_filter].toLowerCase().contains(query.toLowerCase())) {
            if (results.containsKey(date)) {
              results[date].add(record);
            }
            else {
              results[date] = [record];
              resultsUI.add(
                ListTile(
                  title: Text(getFullDate(date),
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                )
              );
            }

            resultsUI.add(
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => RecordDetailPage(dataKeys[keyIndex], index)
                  ));
                },
                child: buildCard(data, dataKeys[keyIndex], index, sortedDataKeys: dataKeys)
              )
            );
          }
        }
      }

      if (results.isEmpty) {
        resultsUI.add(
          Container(
            alignment: Alignment.center,
            child: ListTile(
              leading: Icon(Icons.sentiment_dissatisfied,
                color: Colors.black54,
              ),
              title: Container(
                child: Text("No matching results..."),
              ),
            )
          )
        );
      }

      resultsUI.insert(0, 
        ListTile(
          leading: Icon(Icons.filter_list),
          title: Text("Filtered by '${_filter == "name" ? 'Item Name' : _filter == "amount" ? 'Price' : _filter == "payMode" ? 'Payment Mode' : 'Note'}'",
            style: TextStyle(
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
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
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