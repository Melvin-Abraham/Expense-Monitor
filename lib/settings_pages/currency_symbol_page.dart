import 'package:flutter/material.dart';

import 'package:expense_monitor/main.dart';
import 'package:expense_monitor/func_lib.dart';

class CurrencySymbolPage extends StatefulWidget {
  @override
  _CurrencySymbolPageState createState() => _CurrencySymbolPageState();
}

class _CurrencySymbolPageState extends State<CurrencySymbolPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Symbol Apperance"),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0
              ),

              margin: EdgeInsets.only(
                top: 20.0,
                left: 10.0,
                right: 10.0,
                bottom: 20.0
              ),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0)
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.0
                    ),
                  ),
                  Text("Sample",
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.0
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.bubble_chart,
                        color: Colors.black45,
                        size: 30.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5.0
                        ),
                      ),
                      Text("${currencyList[data["settings"]["currency"]]["name"]}",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black45,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10.0
                        ),
                      ),
                      () {
                        String symbolType = data["settings"]["symbol_type"];
                        String currencyCode = data["settings"]["currency"];
                        Map<String, dynamic> currency = currencyList[currencyCode];
                        
                        return Text("${currency[symbolType]} ",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold
                          ),
                        );
                      }(),
                      Text("50",
                        style: TextStyle(
                          fontSize: 18.0
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.0
                    ),
                  ),
                ],
              ),
            ),

            FlatButton(
              onPressed: () {
                setState(() {
                  data["settings"]["symbol_type"] = "code";
                  saveData();
                });
              },
              child: ListTile(
                leading: (data["settings"]["symbol_type"] != "code")
                  ? Icon(Icons.done,
                    color: Colors.black12,
                    size: 30.0,
                  ) 
                  : Icon(Icons.done,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                title: Text("Currency Code",
                  style: TextStyle(
                    color: (data["settings"]["symbol_type"] != "code") ? Colors.black : Colors.blue
                  ),
                ),
                subtitle: Text("${currencyList[data["settings"]["currency"]]["code"]}",
                  style: TextStyle(
                    color: (data["settings"]["symbol_type"] != "code") ? Colors.black54 : Colors.blue[400]
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  data["settings"]["symbol_type"] = "symbol";
                  saveData();
                });
              },
              child: ListTile(
                leading: (data["settings"]["symbol_type"] != "symbol")
                  ? Icon(Icons.done,
                    color: Colors.black12,
                    size: 30.0,
                  ) 
                  : Icon(Icons.done,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                title: Text("Gerneric Symbol",
                  style: TextStyle(
                    color: (data["settings"]["symbol_type"] != "symbol") ? Colors.black : Colors.blue
                  ),
                ),
                subtitle: Text("${currencyList[data["settings"]["currency"]]["symbol"]}",
                  style: TextStyle(
                    color: (data["settings"]["symbol_type"] != "symbol") ? Colors.black54 : Colors.blue[400]
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  data["settings"]["symbol_type"] = "symbol_native";
                  saveData();
                });
              },
              child: ListTile(
                leading: (data["settings"]["symbol_type"] != "symbol_native")
                  ? Icon(Icons.done,
                    color: Colors.black12,
                    size: 30.0,
                  ) 
                  : Icon(Icons.done,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                title: Text("Native Symbol",
                  style: TextStyle(
                    color: (data["settings"]["symbol_type"] != "symbol_native") ? Colors.black : Colors.blue
                  ),
                ),
                subtitle: Text("${currencyList[data["settings"]["currency"]]["symbol_native"]}",
                  style: TextStyle(
                    color: (data["settings"]["symbol_type"] != "symbol_native") ? Colors.black54 : Colors.blue[400]
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
