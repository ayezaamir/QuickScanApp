import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickscan/scanmodel.dart';
import 'package:quickscan/scannerscreen.dart';
import 'package:quickscan/unsplash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(ScanItemAdapter()); // Register the generated adapter

  await Hive.openBox<ScanItem>('scans'); // Open a box called 'scans'

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Scanner App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,),
      ),
      home: SplashScreen(),
    );
  }
}
