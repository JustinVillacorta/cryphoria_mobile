import 'package:cryphoria_mobile/features/auth/presentation/pages/Home/home_views/homeView.dart';
import 'package:cryphoria_mobile/features/auth/presentation/widgets/widgetTree.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: WidgetTree(),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
      )
    

    
    );
  }
}


