import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'utils.dart' as utils;
import 'appointments/appointments.dart';
import 'contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';

void main() {
  start() async {
    runApp(const MyApp());

    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
  }

  start();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Book'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  static final List<Widget> _widgetList = <Widget>[
    Appointments(),
    Contacts(),
    Notes(),
    Tasks()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range_outlined),
            label: "Compromissos"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            label: "Contatos"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            label: "Notas"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: "Tarefas"
          )
        ],

        currentIndex: _currentPageIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        showSelectedLabels: false,
      ),

      body: _widgetList.elementAt(_currentPageIndex)
    );
  }
}
