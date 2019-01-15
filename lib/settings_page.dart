import 'package:flutter/material.dart';

import './main.dart';
import './settings_pages/currency_page.dart';
import './settings_pages/currency_symbol_page.dart';
import './settings_pages/legal_notices_page.dart';
import './settings_pages/about_page.dart';
import './settings_pages/google_signin_page.dart';
import './settings_pages/cloud_page.dart';
import './settings_pages/cloud_delete_page.dart';
import './settings_pages/changelog_page.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),

      body: Container(
        padding: EdgeInsets.only(
          top: 0.0
        ),
        child: ListView(
          children: <Widget>[
            // Container(
            //   padding: EdgeInsets.only(
            //     left: 32.0,
            //     top: 20.0,
            //     bottom: 15.0
            //   ),
            //   child: Text("Settings",
            //     style: TextStyle(
            //       color: Colors.indigo,
            //       fontSize: 40.0,
            //       fontWeight: FontWeight.bold
            //     ),
            //   ),
            // ),
            Container(
              padding: EdgeInsets.only(
                left: 32.0,
                top: 20.0,
                bottom: 10.0
              ),
              child: Text("PRIMARY",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CurrencyPage()
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.swap_vertical_circle,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  subtitle: () {
                    String currency = data["settings"]["currency"];

                    if (currencyList.containsKey(currency)) {
                      return Text("${currencyList[currency]["name"]} ($currency)");
                    }
                    else {
                      return Text("Invalid Currency");
                    }
                  }(),
                  title: Text("Currency",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CurrencySymbolPage()
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.bubble_chart,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  subtitle: Text("Change the Currency Symbol Apperance"),
                  title: Text("Currency Symbol Apperance",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 32.0,
                top: 20.0,
                bottom: 10.0
              ),
              child: Text("CLOUD BACKUP",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    if (googleSignIn.currentUser == null)
                      return GoogleSignInPage();

                    return CloudPage('export');
                  }
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.cloud_upload,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  title: Text("Export to Cloud",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    if (googleSignIn.currentUser == null)
                      return GoogleSignInPage();

                    return CloudPage('import');
                  }
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.cloud_download,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  title: Text("Import from Cloud",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    if (googleSignIn.currentUser == null)
                      return GoogleSignInPage();

                    return CloudDeletePage();
                  }
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.delete,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  subtitle: Text("Remove Records from Cloud"),
                  title: Text("Delete from Cloud",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 32.0,
                top: 20.0,
                bottom: 10.0
              ),
              child: Text("SIGN IN ACCOUNT",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => GoogleSignInPage()
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.account_circle,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  title: Text("Google Sign in",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 32.0,
                top: 20.0,
                bottom: 10.0
              ),
              child: Text("INFO",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AboutPage()
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.info_outline,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  subtitle: Text("v$version"),
                  title: Text("About",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => LegalNoticesPage()
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.only(
                      left: 2.0
                    ),
                    child: Image.asset("assets/license.png",
                      scale: 2.0,
                    ),
                  ),
                  title: Text("Legal Notices",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ChangelogPage()
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0
                ),
                child: ListTile(
                  leading: Icon(Icons.new_releases,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  title: Text("Changelog",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
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