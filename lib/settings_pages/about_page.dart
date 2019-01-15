import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:expense_monitor/main.dart';
import 'package:expense_monitor/settings_pages/license_page.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    const double topPadding = 182.0;
    
    return Scaffold(
      body: Container(
        child: Stack(
          alignment: Alignment(0.0, 1.0),
          children: <Widget>[
            Positioned(
              top: 0.0,
              left: 0.0,
              width: MediaQuery.of(context).size.width,
              height: 255.5,
              child: Container(
                child: Image.asset("assets/purple-ink-in-water.jpg",
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0)
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color.fromARGB(50, 0, 0, 0),
                            blurRadius: 6.0,
                            offset: Offset(0, 3)
                          )
                        ]
                      ),
                      margin: EdgeInsets.only(
                        top: topPadding,        // TODO: Slide animation
                        left: 20.0,
                        right: 20.0,
                        bottom: 30.0
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              top: 82.0
                            ),
                          ),
                          Text("Expense Monitor",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 30.0
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10.0
                            ),
                          ),
                          Text("Version $version",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 20.0
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 35.0
                            ),
                          ),
                          Text("Expense Monitor is an open-source project. Check out the source code.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 16.0
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 30.0
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              const urlString = "https://github.com/Melvin-Abraham/Expense-Monitor";

                              () async {
                                if (await canLaunch(urlString)) {
                                  launch(urlString);
                                }
                                else {
                                  SnackBar snackbar = SnackBar(
                                    content: Text("Failed to launch the link!"),
                                  );

                                  Scaffold.of(context).showSnackBar(snackbar);
                                }
                              }();
                            },
                            textColor: Colors.blue,
                            color: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0)
                              )
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 8.0
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset("assets/github-logo.png",
                                  scale: 18.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 12.0
                                  ),
                                ),
                                Text("Fork on Github",
                                  style: TextStyle(
                                    fontSize: 16.0
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 30.0
                            ),
                          ),
                          Divider(
                            color: Colors.black45,
                          ),
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
                            textColor: Colors.blue,
                            child: ListTile(
                              leading: Image.asset("assets/license.png",
                                scale: 1.75,
                              ),
                              title: Text("View Application License",
                                style: TextStyle(
                                  color: Colors.blue
                                ),
                              ),
                              subtitle: Text("Apache License 2.0"),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 10.0
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 112.0,
                      left: 0.0,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(
                                50,
                                Colors.indigo.red,
                                Colors.indigo.green,
                                Colors.indigo.blue
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(90.0)
                              )
                            ),
                            child: Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(
                                  70,
                                  Colors.indigo.red,
                                  Colors.indigo.green,
                                  Colors.indigo.blue
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(90.0)
                                )
                              ),
                              child: Image.asset("assets/favicon.png",
                                scale: 1.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}