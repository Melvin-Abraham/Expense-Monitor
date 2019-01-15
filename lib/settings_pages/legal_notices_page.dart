import 'package:flutter/material.dart';

import 'package:expense_monitor/settings_pages/license_page.dart';
import 'package:expense_monitor/main.dart';

class LegalNoticesPage extends StatefulWidget {
  @override
  _LegalNoticesPageState createState() => _LegalNoticesPageState();
}

class _LegalNoticesPageState extends State<LegalNoticesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Legal Notices"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => AppLicensePage()
              ));
            },
            child: ListTile(
              title: Text("Application License",
                style: TextStyle(
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => LicensePage(
                  applicationVersion: "v$version",
                  applicationLegalese: "Third Party Open-Source Licenses",
                )
              ));
            },
            child: ListTile(
              title: Text("Third Party Open-Source Licenses",
                style: TextStyle(
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
