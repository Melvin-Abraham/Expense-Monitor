import 'package:flutter/material.dart';

import 'package:expense_monitor/main.dart';
import 'package:expense_monitor/func_lib.dart';

List<String> currencyKeys = currencyList.keys.toList();
String searchTerm = "";

class CurrencyPage extends StatefulWidget {
  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    currencyKeys.sort((a, b) => currencyList[a]["name"].compareTo(currencyList[b]["name"]));

    searchController.addListener(() {setState(() {});});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  
  List<Widget> getCurrencyList() {
    List<Widget> widgetList = [];
    
    for (int index = 0; index < currencyList.length; index++) {
      String currencyCode = currencyKeys[index];
      Map<String, dynamic> currency = currencyList[currencyCode];
      
      if (currencyCode.toLowerCase().contains(searchController.text.toLowerCase()) ||
          currency["name"].toLowerCase().contains(searchController.text.toLowerCase()) ||
          currency["symbol_native"].contains(searchController.text.toLowerCase()) ||
          currency["symbol"].contains(searchController.text.toLowerCase())) {

        widgetList.add(
          FlatButton(
            onPressed: () {
              data["settings"]["currency"] = currencyCode;
              saveData();
              Navigator.pop(context);
            },
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: (data["settings"]["currency"] != currencyCode) 
                ? Icon(Icons.done,
                  color: Colors.black12,
                  size: 30.0,
                ) 
                : Icon(Icons.done,
                  color: Colors.blue,
                  size: 30.0,
                ),
              title: Text(currency["name"],
                style: TextStyle(
                  color: (data["settings"]["currency"] != currencyCode) ? Colors.black : Colors.blue
                ),
              ),
              subtitle: Text("$currencyCode (${currency["symbol_native"]})",
                style: TextStyle(
                  color: (data["settings"]["currency"] != currencyCode) ? Colors.black54 : Colors.blue[400]
                ),
              ),
            ),
          )
        );
      }
    }

    return widgetList;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Currency"),
      ),

      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Card(
                elevation: 10.0,
                child: TextField(
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search",
                    prefixText: "    "
                  ),
                  controller: searchController,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: getCurrencyList(),
              )
            )
          ],
        ),
      ),
    );
  }
}
