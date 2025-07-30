import 'package:cryphoria_mobile/features/presentation/widgets/widgetTree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(
    const CupertinoApp(
      theme: CupertinoThemeData(primaryColor: Colors.purple, scaffoldBackgroundColor: Colors.black),
      home: WidgetTree(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
