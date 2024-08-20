import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/pages/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    //hides the system bars(status bar and navigation bar) but reveals itself when we swipe 
    //(more like a full screen feature)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0F111D)
      ),
      home: HomePage(),
    );
  }
}
