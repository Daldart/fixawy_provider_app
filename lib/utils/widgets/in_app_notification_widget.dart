import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../colors.dart';

class NotificationBody extends StatelessWidget {

  final String? subject;
  final String? body;

  const NotificationBody({super.key, this.subject, this.body});

  @override
  Widget build(BuildContext context) {
    final minHeight = math.min(0.0,
      MediaQuery.of(context).size.height,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: appButtonColorDark,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      "$subject $body",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
