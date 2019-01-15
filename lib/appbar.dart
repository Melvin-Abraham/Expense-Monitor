import 'package:flutter/material.dart';
import 'dart:math' as math;
import './anim_lib.dart';

/// This `SliverPersistentHeaderDelegate` provides a **customized** version of `SliverAppBar`...
class MySliverPersistenceHeaderDelegate extends SliverPersistentHeaderDelegate {

  MySliverPersistenceHeaderDelegate({
    @required this.title,
    @required this.titleSizeExpanded,
    @required this.titleColor,
    @required this.actions
  });

  final String title;
  final Color titleColor;
  final double titleSizeExpanded;
  final List<Widget> actions;

  @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

      double currentExtent() => math.max(minExtent, maxExtent - shrinkOffset);

      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/material_night.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.indigo, BlendMode.overlay)
          ),
          color: Colors.grey[100],
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black38,
              blurRadius: 7.0,
            ),
          ]
        ),
        child: Stack(
          alignment: AlignmentDirectional(0.0, 1.0),
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: getTweenValue(
                        currentExtent(),
                        minExtent,
                        maxExtent,
                        200.0,
                        viewportWidth(context),
                        EasingCurve.easeInQuint
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                            style: TextStyle(
                              fontSize: map(currentExtent(), minExtent, maxExtent, 20.0, titleSizeExpanded),
                              color: titleColor,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ),
                    ),
                  ]
                )
              ],
            ),

            // For the ripple effect to show up we need a Material...
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(map(currentExtent(), minExtent, maxExtent, 0, 200).toInt(), 0, 0, 0)
                    ]
                  )
                ),
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
            ),
          ]
        ),
      );
    }

  @override
    bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
      return false;
    }

  @override
    double get maxExtent => 260.0;

  @override
    double get minExtent => 60.0;
}
