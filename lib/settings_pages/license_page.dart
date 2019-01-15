import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AppLicensePage extends StatefulWidget {
  @override
  _AppLicensePageState createState() => _AppLicensePageState();
}

class _AppLicensePageState extends State<AppLicensePage> {

  List<Widget> licenseWidgets = [];

  Future<String> loadLicenseText() async {
    String licenseText = await rootBundle.loadString("assets/license/LICENSE");
    return licenseText;
  }

  Future<Null> setLicenseWidgets() async {
    String licenseText = await loadLicenseText();
    double paddingFactor = 30.0;
    List<LicenseParagraph> paragraphs;

    var licenseEntry = LicenseEntryWithLineBreaks(
      ["expense_monitor"],
      licenseText
    );

    paragraphs = licenseEntry.paragraphs.toList();
    
    for (int i = 0; i < paragraphs.length; i++) {
      LicenseParagraph para = paragraphs[i];
      bool isTitle = (para.indent == -1);

      if (!para.text.startsWith("==="))
        licenseWidgets.add(
          Container(
            padding: EdgeInsets.only(
              left: (!isTitle) ? para.indent * paddingFactor : 0.0,
              right: (!isTitle) ? paddingFactor : 0.0,
              top: (!para.text.startsWith("Copyright")) ? 10.0 : 25.0,
              bottom: (!(isTitle || para.text.startsWith("Copyright"))) ? 10.0 : 25.0,
            ),

            child: Text(para.text,
              textAlign: (isTitle)
                ? TextAlign.center
                : (para.text.startsWith("Copyright"))
                  ? TextAlign.justify
                  : TextAlign.start,

              style: TextStyle(
                fontWeight: (isTitle)
                  ? FontWeight.w800
                  : (para.text.startsWith("Copyright"))
                    ? FontWeight.w700
                    : FontWeight.normal
              ),
            ),
          )
        );

      else
        licenseWidgets.addAll([
          Padding(
            padding: EdgeInsets.only(
              top: 20.0
            ),
          ),
          Divider(
            color: Colors.black45,
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 20.0
            ),
          ),
        ]);
    }

    licenseWidgets.add(
      Padding(
        padding: EdgeInsets.only(
          bottom: 20.0
        ),
      )
    );
  }

  @override
  void initState() {
    () async {
      await setLicenseWidgets();
      setState(() {});
    }();

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Application License"),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(50, 0, 0, 0),
                    blurRadius: 5.0
                  )
                ]
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: 30.0
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset("assets/license_color.png",
                        fit: BoxFit.scaleDown,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 30.0
                    ),
                  ),
                  Text("Licensed Under",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 16.0
                    ),
                  ),
                  Text("Apache License 2.0",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 30.0
                    ),
                  ),
                ]
              ),
            )
          ]..addAll(
            (licenseWidgets.isNotEmpty)
              ? licenseWidgets
              : [
                Container(
                  padding: EdgeInsets.only(
                    top: 20.0
                  ),
                  child: Center(
                    child: CircularProgressIndicator()
                  )
                )
              ]
          ),
        ),
      ),
    );
  }
}
