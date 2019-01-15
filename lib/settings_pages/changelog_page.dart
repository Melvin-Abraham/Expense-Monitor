import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:expense_monitor/anim_lib.dart';

List<String> changelogLines;

class ChangelogPage extends StatefulWidget {
  @override
  _ChangelogPageState createState() => _ChangelogPageState();
}

class _ChangelogPageState extends State<ChangelogPage> {
  @override
  void initState() {
    () async {
      String changelogString = await rootBundle.loadString("assets/changelog/CHANGELOG.txt");
      changelogLines = changelogString.split('\n');
      setState(() {});
    }();

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              delegate: ChangelogSliverPersistentHeaderDelegate(),
            ),
            (changelogLines != null)
              ? SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 5.0
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        )
                      ),
                      child: Column(
                        children: getChangelogWidgets(),
                      ),
                    )
                  ]
                ),
              )
            : SliverFillRemaining(
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(
                    top: 20.0
                  ),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

List<Widget> getChangelogWidgets() {
  List<Widget> list = [];

  if (changelogLines != null) {
    for (int lineIndex = 0; lineIndex < changelogLines.length; lineIndex++) {
      String line = changelogLines[lineIndex];

      if (line.startsWith("#")) {
        String text = line.replaceFirst("#", "").trimLeft();
        List<String> tokens = text.split(" ");
        print(tokens);

        String versionLabel = tokens[0];
        String tag = (tokens.length > 1) ? tokens[1] : "";

        list.add(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 20.0
            ),
            title: Row(
              children: <Widget>[
                Text("Version $versionLabel",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 22.0
                  ),
                ),
                (tag != "") ?
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 10.0
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0)
                            )
                          ),
                          child: Text(tag,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
              ],
            ),
          )
        );
      }
      else if (line == "") {
        list.add(
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0
            ),
          )
        );
      }
      else if (line.startsWith("-")) {
        String text = line.replaceFirst("-", "").trimLeft();

        list.add(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 20.0
            ),
            leading: Icon(Icons.keyboard_arrow_right,
              size: 30.0,
            ),
            title: Text(text,
              style: TextStyle(
                fontSize: 17.0
              ),
            )
          )
        );
      }
      else if (line.startsWith("---") || line.startsWith("===")) {
        list.add(
          Divider()
        );
      }
    }
  }

  list.add(
    Padding(
      padding: EdgeInsets.only(
        bottom: 15.0
      ),
    )
  );
  
  return list;
}

class ChangelogSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double currentExtent() => math.max(minExtent, maxExtent - shrinkOffset);

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: maxExtent,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/changelog_back@2x.png"),
                fit: BoxFit.cover
              )
            ),
          ),
          Container(
            height: maxExtent,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/changelog_mid@2x.png"),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight
              )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.new_releases,
                color: Color.fromARGB(
                  getTweenValue(currentExtent(), minExtent, maxExtent, 0.0, 255.0, EasingCurve.easeOutCubic).toInt(),
                  Colors.white.red,
                  Colors.white.green,
                  Colors.white.blue
                ),
                size: 70.0
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: getTweenValue(currentExtent(), minExtent, maxExtent, 0.0, 25.0, EasingCurve.easeOutCubic)
                ),
              ),
              Text("Changelog",
                style: TextStyle(
                  color: Color.fromARGB(
                    getTweenValue(currentExtent(), minExtent, maxExtent, 0.0, 255.0, EasingCurve.easeOutCubic).toInt(),
                    Colors.white.red,
                    Colors.white.green,
                    Colors.white.blue
                  ),
                  fontSize: 30.0,
                  shadows: <BoxShadow>[
                    BoxShadow(
                      color: Color.fromARGB(
                        getTweenValue(currentExtent(), minExtent, maxExtent, 0.0, 75.0, EasingCurve.easeOutCubic).toInt(),
                        Colors.black.red,
                        Colors.black.green,
                        Colors.black.blue
                        ),
                      blurRadius: 6.0,
                      offset: Offset(0, 3)
                    )
                  ]
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  double get minExtent => 10.0;
  double get maxExtent => 260.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
