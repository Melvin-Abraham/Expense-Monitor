import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';

import './home_page.dart';

void main() => runApp(
  MaterialApp(
    title: "Expense Monitor",
    home: Scaffold(body: MyApp()),
    theme: ThemeData(
      primarySwatch: Colors.indigo,
      fontFamily: 'ProductSans',
    ),
    debugShowCheckedModeBanner: false,
  )
);

String version = "x";
PackageInfo packageInfo;

Map<String, dynamic> data = {
  "settings": {
    "currency": "INR",
    "symbol_type": "symbol_native"
  },

  "records": {}
};

GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser user;

List<String> dataKeys = [];
Map<String, dynamic> currencyList = {};

enum PayMode {
  cash,
  e_wallet,
  online,
  c_card,
  d_card,
  unpaid,
}
