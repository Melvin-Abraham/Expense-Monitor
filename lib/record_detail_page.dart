import 'package:flutter/material.dart';

import './main.dart';
import './func_lib.dart';
import './add_record_page.dart';

class RecordDetailPage extends StatefulWidget {
  final String date;
  final int recordIndex;
  
  RecordDetailPage(this.date, this.recordIndex);
  
  @override
  _RecordDetailPageState createState() => _RecordDetailPageState(date, recordIndex);
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final String date;
  final int recordIndex;
  Map<String, String> record;
  int deleteIndex = -1;     // `-1` means not deleted
  List<Map<String, String>> editHistory = [];   // Contains list of new records...
  int historyIndex = 0;

  _RecordDetailPageState(this.date, this.recordIndex) {
    editHistory.add(getRecord(data, this.date, this.recordIndex));
    record = editHistory[historyIndex];
  }
  
  @override
  Widget build(BuildContext context) {
    String symbolType = data["settings"]["symbol_type"];
    String currencyCode = data["settings"]["currency"];
    Map<String, dynamic> currency = currencyList[currencyCode];

    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    
    return Scaffold(
      key: scaffoldKey,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 20.0
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.0
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(50, 0, 0, 0),
                        offset: Offset(0, 2),
                        blurRadius: 5.0,
                        spreadRadius: 2.0
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 0.0
                        ),
                      ),
                      GestureDetector(
                        onDoubleTap: () {
                          if (deleteIndex == -1) {
                            // if record is NOT deleted
                            
                            () async {
                              int selectedHistoryIndex;

                              selectedHistoryIndex = await showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                          top: 20.0,
                                          left: 30.0
                                        ),
                                        child: Row(
                                          children: [
                                            Text("Edit History",
                                              style: TextStyle(
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ]
                                        )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 20.0
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: editHistory.length,
                                          itemBuilder: (context, index) {
                                            return FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, index);
                                              },
                                              child: ListTile(
                                                leading: Icon(Icons.history,
                                                  size: 27.0,
                                                  color: (index < historyIndex)
                                                            ? Colors.black
                                                            : (index > historyIndex)
                                                              ? Colors.black45
                                                              : Colors.blue,
                                                ),
                                                title: Text((index == 0)
                                                              ? "Initial State"
                                                              : (index == editHistory.length - 1)
                                                                ? "Latest State"
                                                                : "Edit #$index",
                                                  style: TextStyle(
                                                    fontSize: 17.0,
                                                    color: (index < historyIndex)
                                                              ? Colors.black
                                                              : (index > historyIndex)
                                                                ? Colors.black45
                                                                : Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              );

                              if (selectedHistoryIndex != null) {
                                historyIndex = selectedHistoryIndex;
                                record = editHistory[historyIndex];

                                setState(() {});
                              }
                            }();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 100.0
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: getColorList(record["payMode"]),
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(
                                  50, 
                                  getColorList(record["payMode"])[0].red,
                                  getColorList(record["payMode"])[0].green,
                                  getColorList(record["payMode"])[0].blue
                                ),
                                offset: (deleteIndex == -1) ? Offset(0, 2) : Offset(0, 0),
                                blurRadius: 8.0,
                                spreadRadius: (deleteIndex == -1) ? 10.0 : 8.0
                              )
                            ],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Hero(
                                tag: '$date-$recordIndex-icon',
                                child: Icon(getPaymentIcon(this.record["payMode"]),
                                  color: (deleteIndex == -1) ? Colors.white : Colors.white70,
                                  size: 50.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 15.0
                                ),
                              ),
                              Text(expandPaymentMode(this.record["payMode"]),
                                style: TextStyle(
                                  color: (deleteIndex == -1) ? Colors.white : Colors.white70,
                                  fontSize: 30.0
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 20.0
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 30.0
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.label,
                                      color: Colors.black54,
                                      size: 22.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 8.0
                                      ),
                                    ),
                                    Text(getFullDate(date),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                        fontSize: 16.0
                                      )
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      child: Text(weekday(date).toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.black54
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 20.0
                              ),
                            ),
                            Text((record["name"].trim() != "") ? record["name"] : "No Name",
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (record["name"].trim() != "") ? Colors.black : Colors.black54,
                                fontSize: 30.0
                              )
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0
                              ),
                            ),
                            Text((record["amount"].trim() != "")
                              ? "${currency[symbolType]} ${record["amount"]}"
                              : "${currency[symbolType]}   Unknown",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: (record["payMode"] == "unpaid")
                                  ? Colors.redAccent
                                  : (record["amount"].trim() != "")
                                    ? Colors.blue
                                    : Colors.black54,
                              ),
                            ),
                            Divider(
                              height: 30.0,
                              color: Colors.black45,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Icon(Icons.note,
                                  color: getColorList(record["payMode"])[0],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 10.0
                                  ),
                                ),
                                Text("NOTE",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: getColorList(record["payMode"])[0],
                                    fontWeight: FontWeight.w400
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 20.0
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 30.0
                              ),
                              child: Text((record["note"].trim() != "")
                                ? "${record["note"]}"
                                : "No Note",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: (record["note"].trim() != "") ? Colors.black : Colors.black54
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 40.0
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    if (historyIndex == editHistory.length - 1) {
                                      // if `Latest State`
                                      print("Deleting / Undeleting...");

                                      if (deleteIndex == -1) {
                                        // if `record is NOT deleted`
                                        //     => DELETE record
                                        
                                        setState(() {
                                          deleteIndex = removeRecord(context, record, date);
                                          dataKeys = getSortedDataKeys();
                                        });
                                      }
                                      else {
                                        // if `record is deleted`
                                        //     => RECOVER record

                                        if (data["records"].containsKey(date)) {
                                          data["records"][date].insert(deleteIndex, record);
                                          setState(() {});
                                        }
                                        else {
                                          data["records"][date] = [record];

                                          setState(() {
                                            dataKeys = getSortedDataKeys();
                                          });
                                        }

                                        deleteIndex = -1;
                                      }
                                      
                                      saveData();
                                    }

                                    else {
                                      print("Preventing Delete...");
                                      
                                      SnackBar snackbar = SnackBar(
                                        content: Text("Can't Delete, please switch to the \"Latest State\"..."),
                                      );

                                      scaffoldKey.currentState.showSnackBar(snackbar);
                                    }
                                  },
                                  textColor: (historyIndex == editHistory.length - 1)
                                                ? getColorList(record["payMode"])[1]
                                                : Colors.black54,
                                  child: Text((deleteIndex == -1) ? "DELETE" : "UNDO DELETE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 230.0,
                right: 20.0,
                child: Container(
                  padding: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      45,
                      Colors.indigo.red,
                      Colors.indigo.green,
                      Colors.indigo.blue,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0)
                    )
                  ),
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                        60,
                        Colors.indigo.red,
                        Colors.indigo.green,
                        Colors.indigo.blue,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(50.0)
                      )
                    ),
                    child: FloatingActionButton(
                      onPressed: (deleteIndex == -1)
                        ? () {
                          if (historyIndex == editHistory.length - 1) {
                            // if `Latest State`
                            
                            () async {
                              Map<String, dynamic> edits = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) => AddRecord(
                                  editDate: date,
                                  editRecordData: record
                                )
                              ));

                              setState(() {
                                if (edits != null && !isIdenticalRecord(edits["oldRecord"], edits["newRecord"])) {
                                  editHistory.add(edits["newRecord"]);
                                  historyIndex = editHistory.length - 1;
                                  record = editHistory[historyIndex];
                                }
                              });
                            }();
                          }
                          
                          else {
                            data["records"][date][recordIndex] = record;
                            int historyLastIndex = editHistory.length - 1;

                            for (int i = 0; i < historyLastIndex - historyIndex; i++) {
                              editHistory.removeLast();
                            }

                            setState(() {});
                          }
                        }
                        : null,
                      child: Icon((historyIndex < editHistory.length - 1) ? Icons.save : Icons.edit,
                        color: (deleteIndex == -1) ? Colors.white : Colors.white54,
                      ),
                      tooltip: (historyIndex < editHistory.length - 1) ? "Save this State" : "Edit",
                      elevation: 10.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
