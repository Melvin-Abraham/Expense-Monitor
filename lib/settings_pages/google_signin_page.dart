import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

import 'package:expense_monitor/main.dart';
import 'package:expense_monitor/func_lib.dart';

class GoogleSignInPage extends StatefulWidget {
  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  GoogleSignInAccount googleUser;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    googleUser = googleSignIn.currentUser;
    super.initState();

    () async {
      if (await googleSignIn.isSignedIn()) {
        if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
          googleUser = googleSignIn.currentUser;
        }
        else {
          print("Client offline");

          _connectivitySubscription =
              _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
            setState(() {
              if (result != ConnectivityResult.none) {
                googleSignIn.signInSilently();
                googleUser = googleSignIn.currentUser;
              }
              
              if (getSignInStatus(googleUser) == SignInStatus.fullySignedIn)
                _connectivitySubscription.cancel();
            });
          });
        }
      }
    }();
  }

  void _handleSignIn() async {
    try {
      googleUser = await googleSignIn.signIn();
      handleSignIn(auth).then((_) {
        // After successful sign in
        setState(() {});
      });
    }
    catch (e) {
      print("GOOGLE SIGN-IN: EXCEPTION THROWN");
      print(e);
    }

    // If atleast partially signed in
    if (googleUser != null) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Colors.deepPurple[400]
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: ListView(
          // physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10.0
                    ),
                  ),
                  () {
                    SignInStatus signInStatus = getSignInStatus(googleUser);
                    String label;

                    if (signInStatus == SignInStatus.notSignedIn) {
                      label = "Sign in with Google";
                    }
                    else if (signInStatus == SignInStatus.partiallySignedIn) {
                      label = "You are partially signed in";
                    }
                    else {
                      label = "You are signed in!";
                    }

                    TextStyle style = TextStyle(
                      fontSize: 25.0,
                      color: Colors.white
                    );
                    
                    return Text(label,
                      style: style,
                    );
                  }(),
                  // Text((googleUser == null)
                  //         ? "Sign in with Google"
                  //         : (user == null)
                  //           ? "You are partially signed in"
                  //           : "You are signed in!",
                  //   style: TextStyle(
                  //     fontSize: 25.0,
                  //     color: Colors.white
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 40.0
                    ),
                  ),
                  Icon(Icons.cloud,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.0
                    ),
                  ),
                  Text("Sign in with Google in order to enable Cloud Backup functions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 45.0
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          top: 40.0
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color.fromARGB(41, 0, 0, 0),
                                blurRadius: 6.0,
                                offset: Offset(0, 3)
                              )
                            ],
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                            )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 42.0
                                ),
                              ),
                              Text((googleUser == null)
                                      ? "Not Signed in"
                                      : googleUser.displayName,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black54
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 0.0
                                ),
                              ),
                              Text((googleUser == null)
                                      ? "anonymous"
                                      : googleUser.email,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black45
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 42.0
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0.0,
                        left: 0.0,
                        width: MediaQuery.of(context).size.width - 30.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
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
                                              height: 60.0,
                                              width: 60.0,
                                              child: GoogleUserCircleAvatar(
                                                identity: MyGoogleIdentity(googleUser),
                                              )
                                            )
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 45.0
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      SignInStatus signInStatus = getSignInStatus(googleUser);
                      
                      if (signInStatus != SignInStatus.fullySignedIn) {
                        () async {
                          if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
                            _handleSignIn();
                            
                            if (signInStatus == SignInStatus.partiallySignedIn) {
                              print("Fixing Sign in...");

                              SnackBar snackbar = SnackBar(
                                content: Text("Fixing your sign in..."),
                              );

                              key.currentState.showSnackBar(snackbar);
                            }
                          }
                          else {
                            SnackBar snackbar = SnackBar(
                              content: Text("You are offline. Sign-in failed."),
                            );

                            key.currentState.showSnackBar(snackbar);
                          }
                        }();
                      }
                      else {
                        googleSignIn.signOut();

                        setState(() {
                          googleUser = null;
                          user = null;
                        });
                      }
                    },
                    fillColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 12.0
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0)
                      )
                    ),
                    elevation: 10.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        () {
                          SignInStatus signInStatus = getSignInStatus(googleUser);

                          if (signInStatus == SignInStatus.notSignedIn) {
                            return Image.asset("assets/google-favicon.png",
                              scale: 4.0,
                            );
                          }
                          else if (signInStatus == SignInStatus.partiallySignedIn) {
                            return Container(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(Icons.build,
                                size: 25.0,
                              ),
                            );
                          }
                          else {
                            return Icon(Icons.cloud_off,
                              size: 30.0,
                            );
                          }
                        }(),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 16.0
                          ),
                        ),
                        () {
                          SignInStatus signInStatus = getSignInStatus(googleUser);
                          String label;
                          
                          TextStyle style = TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87
                          );

                          if (signInStatus == SignInStatus.notSignedIn) {
                            label = "Sign in with Google";
                          }
                          else if (signInStatus == SignInStatus.partiallySignedIn) {
                            label = "Fix my Sign in";
                          }
                          else {
                            label = "Sign Out";
                          }

                          return Text(label,
                            style: style,
                          );
                        }(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
