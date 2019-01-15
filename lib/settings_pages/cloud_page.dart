import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';

import 'package:expense_monitor/main.dart';
import 'package:expense_monitor/func_lib.dart';

Map<String, dynamic> cloudData;
CollectionReference collection = Firestore.instance.collection("/expense-records");
DocumentReference doc = collection.document(user.uid);
DocumentSnapshot documentSnapshot;
bool hasInternetConnection = true;
bool dataLoaded = false;

final Connectivity _connectivity = Connectivity();
StreamSubscription<ConnectivityResult> _connectivitySubscription;

Future<DocumentSnapshot> getDocumentSnapshot() async {
  // Firestore.instance.runTransaction((transaction) async {
  //   // dataLoaded = false;
  //   documentSnapshot = await transaction.get(doc);
  //   cloudData = documentSnapshot.data;
  //   dataLoaded = true;
  // });

  // In case when `user` previously was null
  doc = collection.document(user.uid);

  documentSnapshot = await doc.get();
  cloudData = documentSnapshot.data;
  dataLoaded = true;

  return documentSnapshot;
}

Widget getNoDataUI(String tag) {
  return SliverFillRemaining(
    child: Container(
      padding: EdgeInsets.only(
        top: 30.0,
        left: 10.0,
        right: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon((tag == 'export')
                  ? Icons.do_not_disturb
                  : (hasInternetConnection)
                    ? (dataLoaded)
                      ? Icons.cloud_off
                      : Icons.cloud_done
                    : Icons.signal_cellular_connected_no_internet_4_bar,

            size: 70.0,
            color: Colors.indigo,
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 20.0
            ),
          ),
          Text((tag == 'export')
                  ? "Seems like you don't have any expense records stored locally!"
                  : (hasInternetConnection)
                    ? (dataLoaded)
                      ? "There's currently nothing to display..."
                      : "Fetching data from Cloud..."
                    : "You are Offline. Consider turning on mobile data or Wi-Fi. Results will automatically load...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 20.0
            ),
          ),
          () {
            return (!dataLoaded)
              ? Container(
                  child: LinearProgressIndicator(),
                )
              : Container();
          }()
        ],
      ),
    )
  );
}

class CloudPage extends StatefulWidget {
  final String tag;
  CloudPage(this.tag);
  
  @override
  _CloudPageState createState() => _CloudPageState(tag);
}

class _CloudPageState extends State<CloudPage> {
  String tag;
  GoogleSignInAccount googleUser;
  GoogleSignInAuthentication gAuth;
  
  _CloudPageState(this.tag);

  @override
  void initState() {
    googleUser = googleSignIn.currentUser;  
    super.initState();

    if (this.tag == 'export') {
      setState(() {
        getDocumentSnapshot();
      });
    }

    () async {
      if (this.tag == 'import') {
        if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
          if (getSignInStatus(googleUser) != SignInStatus.fullySignedIn) {
            handleSignIn(auth);
          }
          
          getDocumentSnapshot().then((_) => setState(() {
            hasInternetConnection = true;
          }));
        }
        else {
          print("No Internet");
          setState(() {
            hasInternetConnection = false;
            dataLoaded = true;
          });
          
          _connectivitySubscription =
              _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {

            setState(() {
              dataLoaded = false;
            });
            
            () async {
              if (getSignInStatus(googleUser) != SignInStatus.fullySignedIn) {
                await handleSignIn(auth);
              }
              
              getDocumentSnapshot().then((_) => setState(() {
                if (result != ConnectivityResult.none) {
                  print("Got Snapshot");
                  hasInternetConnection = true;
                }
                if (hasInternetConnection && dataLoaded)
                  _connectivitySubscription.cancel();

                print("setState...");
              }));
            }();
          });
        }
      }
    }();
  }

  @override
  void dispose() {
    if (!hasInternetConnection || !dataLoaded)
      _connectivitySubscription.cancel();
      
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: (_getScrollOffset(_scrollController) < 150.0) ? 0.0 : 4.0,
        title: Text((tag == "export")
                      ? "Export to cloud"
                      : "Import from Cloud"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.indigo,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              delegate: CloudPageSliverPersistentHeaderDelegate(googleUser, tag),
            ),
            
            ((tag == 'export' && data["records"].keys.length != 0) ||
             (tag == 'import' && cloudData != null && cloudData["records"].keys.length != 0))
                ? SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          // top: 215.0
                        ),
                      ),
                      //,
                      Container(
                        padding: EdgeInsets.only(
                          top: 5.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)
                          )
                        ),
                        child: Column(
                          children: getListUI((tag == 'export')
                                                ? data
                                                : cloudData)
                                    ..insert(0, (tag == 'import' && !hasInternetConnection)
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                        top: 20.0,
                                                        bottom: 10.0,
                                                        left: 10.0,
                                                        right: 10.0,
                                                      ),
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 5.0
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange[100],
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(5.0)
                                                        )
                                                      ),
                                                      child: ListTile(
                                                        leading: () {
                                                          return (dataLoaded)
                                                            ? Icon(Icons.star,
                                                              color: Colors.orange[800],
                                                            )
                                                            : Container(
                                                              height: 15.0,
                                                              width: 15.0,
                                                              child: CircularProgressIndicator(
                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                  Colors.orange[800]
                                                                ),
                                                                strokeWidth: 2.0,
                                                              ),
                                                            );
                                                        }(),
                                                        title: Text((dataLoaded)
                                                                      ? "You're offline! Showing cached copy."
                                                                      : "Hold on. Fetching results...",
                                                          style: TextStyle(
                                                            color: Colors.orange[800]
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                    ),
                        ),
                      )
                    ],
                  )
                )

                : getNoDataUI(tag)
          ],
        ),
      ),
    );
  }
}

class CloudPageSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  GoogleSignInAccount googleUser;
  final String tag;

  CloudPageSliverPersistentHeaderDelegate(this.googleUser, this.tag);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double currentExtent() => math.max(minExtent, maxExtent - shrinkOffset);

    return Container(
      // height: currentExtent(),
      child: Column(
        children: <Widget>[
          Container(
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
                          50,
                          Colors.white.red,
                          Colors.white.green,
                          Colors.white.blue
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(90.0)
                        )
                      ),
                      child: Container(
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                            100,
                            Colors.white.red,
                            Colors.white.green,
                            Colors.white.blue
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
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                        Text(googleUser.email,
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 15.0
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 15.0
            ),
            margin: EdgeInsets.only(
              // top: 125.0,
              left: 20.0
            ),
            color: Colors.indigo,
            child: ListTile(
              contentPadding: EdgeInsets.only(
                left: 0.0
              ),
              leading: Icon((this.tag == 'export')
                              ? Icons.cloud_upload
                              : Icons.cloud_download,
                color: Colors.white,
                size: 30.0,
              ),
              title: Text((this.tag == 'export')
                            ? "Do you want to export this data to the cloud?"
                            : "Do you want to import this data from the cloud?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0
                ),
              ),
              trailing: FlatButton(
                onPressed: () {
                  () async {
                    if (this.tag == 'export') {
                      print("Exporting to Cloud...");

                      if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
                        try {
                          Firestore.instance.runTransaction((transaction) async {
                              if (documentSnapshot.exists) {
                                await transaction.update(doc, data);
                              }
                              else {
                                await transaction.set(doc, data);
                              }
                            }
                          );

                          print("Data Exported successfully!");

                          Flushbar(
                            message: "Data was successfully exported to Cloud...",
                            duration: Duration(seconds: 3),
                          )..show(context);

                          print("Document Snapshot is null");
                        }
                        catch (e) {
                          print(e);

                          Flushbar(
                            message: "Unexpected error occured. Failed to export...",
                            duration: Duration(seconds: 3),
                          )..show(context);
                        }
                      }
                      else {
                        print("Client offline. Export failed...");

                        Flushbar(
                          message: "You are offline. Failed to Export...",
                          duration: Duration(seconds: 3),
                        )..show(context);
                      }

                    }
                    else {
                      print("Importing from Cloud...");

                      () async {
                        if (documentSnapshot.exists) {
                          print(cloudData);

                          if (isValidData(cloudData)) {
                            print("cloudData is Valid...");

                            if (cloudData["records"].isNotEmpty) {
                              print("cloudData contains 'records' field");

                              // The following step ensures that `data` has expense records
                              // stored in "Growable Lists" instead of "Fixed Length Lists".
                              // That also ensures that a record can be deleted with no errors.

                              String dataString = await saveData(cloudData);
                              data = json.decode(dataString);

                              dataKeys = getSortedDataKeys();

                              Flushbar(
                                message: "Successfully imported data from Cloud...",
                                duration: Duration(seconds: 3),
                              )..show(context);
                            }
                            else {
                              Flushbar(
                                message: "Can't import empty records...",
                                duration: Duration(seconds: 3),
                              )..show(context);
                            }
                          }
                          else {
                            Flushbar(
                              message: "Data stored in the Cloud seems to be invalid...",
                              duration: Duration(seconds: 3),
                            )..show(context);
                          }
                          
                          print("Successfully read data from snapshot!");
                        }
                        else {
                          Flushbar(
                            message: "Sorry, No Cloud Backups found!",
                            duration: Duration(seconds: 3),
                          )..show(context);
                          
                          print("Sorry, no Cloud Backups found!");
                        }
                      }();
                    }
                  }();
                },
                textColor: Colors.white,
                child: Text((this.tag == 'export')
                              ? "EXPORT"
                              : "IMPORT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get minExtent => 10.0;
  double get maxExtent => 220.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
