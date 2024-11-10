import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';  
import 'package:student_provider/model/models.dart';
import 'package:student_provider/screens/home/home_screen.dart';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.openBox<StudentModel>('student');
  if(!Hive.isAdapterRegistered(StudentModelAdapter().typeId)){
    Hive.registerAdapter(StudentModelAdapter());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          
        ),

        useMaterial3: false,

        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue).
          copyWith(background: Colors.grey)
      )

    );
  }
}