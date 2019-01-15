import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:connectivity/connectivity.dart';

import 'package:expense_monitor/main.dart';
import 'package:expense_monitor/func_lib.dart';

CollectionReference collection = Firestore.instance.collection("/expense-records");
DocumentReference doc = collection.document(user.uid);
DocumentSnapshot documentSnapshot;
Connectivity _connectivity = Connectivity();
bool loading = false;

class CloudDeletePage extends StatefulWidget {
  @override
  _CloudDeletePageState createState() => _CloudDeletePageState();
}

class _CloudDeletePageState extends State<CloudDeletePage> {
  GoogleSignInAccount googleUser;
  bool acceptBool = false;
  
  @override
  void initState() {
    googleUser = googleSignIn.currentUser;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.indigo[600],
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: 65.0
                    ),
                  ),
                  Icon(Icons.delete,
                    size: 90.0,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 42.0
                    ),
                  ),
                  Text("Delete your Expense Records from Cloud",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 35.0
                    ),
                  ),
                  Text("Do you really want to remove all your expense records from the Cloud?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 30.0
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(50, 0, 0, 0),
                          blurRadius: 6.0,
                          offset: Offset(0, 3)
                        )
                      ]
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 10.0
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(0.0),
                          leading: Container(
                            padding: EdgeInsets.only(
                              top: 30.0,
                              left: 20.0,
                              right: 20.0
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(
                                          80,
                                          Colors.indigo.red,
                                          Colors.indigo.green,
                                          Colors.indigo.blue
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(90.0)
                                        )
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(2.0),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            150,
                                            Colors.indigo.red,
                                            Colors.indigo.green,
                                            Colors.indigo.blue
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(90.0)
                                          )
                                        ),
                                        child: (googleUser == null)
                                                  ? Icon(Icons.account_circle,
                                                      size: 60.0,
                                                      color: Colors.blue,
                                                    )
                                                  : Container(
                                                      height: 55.0,
                                                      width: 55.0,
                                                      child: GoogleUserCircleAvatar(
                                                        identity: MyGoogleIdentity(googleUser),
                                                      )
                                                    )
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 20.0
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(googleUser.displayName,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0
                                          ),
                                        ),
                                        Text(googleUser.email,
                                          style: TextStyle(
                                            color: Colors.black
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 30.0
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 10.0
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            if (acceptBool) {
                              return () {
                                () async {
                                  if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
                                    setState(() {
                                      loading = true;
                                    });

                                    documentSnapshot = await doc.get();

                                    setState(() {
                                      loading = false;
                                    });
                                    
                                    if (documentSnapshot.exists) {
                                      int option = await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, 1);
                                              },
                                              child: Text("PROCEED",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, 0);
                                              },
                                              child: Text("CANCEL",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)
                                            )
                                          ),
                                          title: Text("Delete from Cloud?",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          content: Text("This will delete your expense records from Cloud. This action cannot be undone."),
                                        )
                                      );

                                      if (option == 1) {
                                        doc.delete();

                                        var flushbar = Flushbar(
                                          message: "Your Expense Records are successfully removed from Cloud...",
                                          duration: Duration(seconds: 3),
                                        );

                                        await flushbar.show(context);
                                        Navigator.pop(context);
                                      }
                                    }
                                    else {
                                      Flushbar(
                                        message: "You don't have any Cloud Backups to delete...",
                                        duration: Duration(seconds: 3),
                                      )..show(context);
                                    }
                                  }
                                  else {
                                    Flushbar(
                                      message: "You are offline...",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                  }
                                }();
                              };
                            }
                            else {
                              return null;
                            }
                          }(),
                          textColor: Colors.red,
                          color: Colors.red[50],
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
                              (!loading)
                              ? Icon(Icons.delete,
                                  size: 28.0,
                                )
                              : Container(
                                margin: EdgeInsets.only(
                                  right: 2.0
                                ),
                                padding: EdgeInsets.only(
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                height: 15.0,
                                width: 15.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation(Colors.red),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 12.0
                                ),
                              ),
                              Text("Delete",
                                style: TextStyle(
                                  fontSize: 18.0
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 20.0
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        acceptBool = !acceptBool;
                      });
                    },
                    child: ListTile(
                      leading: Icon((acceptBool)
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                        color: Colors.white
                      ),
                      title: Text("I am completely aware of my action",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.0
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
