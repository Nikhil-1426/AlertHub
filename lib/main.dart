import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'LoadingPage.dart'; // or your initial page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlertHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingPage(), // Or your initial page
    );
  }
}

