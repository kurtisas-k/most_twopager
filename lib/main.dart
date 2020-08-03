import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      home: FlutterDemo(storage: CounterStorage()),
    ),
  );
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File> get  _localFile async {

    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<String> readText() async {
    try {
      final file = await _localFile;
      // Read the file
      return await file.readAsString();
    } catch (e) {
      // If encountering an error, return 0
      return "Contents of the textfield";
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$counter');
  }
  
  Future<File> writeText(String text) async {
    final file = await _localFile;
    // Write the file
    print("some $text");
    return file.writeAsString('$text');
  }
}

class FlutterDemo extends StatefulWidget {
  final CounterStorage storage;

  FlutterDemo({Key key, @required this.storage}) : super(key: key);

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });

    widget.storage.readText().then((String goal){
      setState(() {
        _controller = TextEditingController();
        _controller.text = goal;
      });
    });

  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });
    // Write the variable as a string to the file.
    return widget.storage.writeCounter(_counter);
  }

  Future<File> _saveGoal() {
    // Write the variable as a string to the file.
    return widget.storage.writeText(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading and Writing Files')),
      body: Column(
        children: <Widget>[
          Text(
            '_goalStats',
          ),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.done,
              maxLines: null,
              controller: _controller,
              onSubmitted: (String value) async {

                // todo: move action from onSubmitted to set button onPressed
                // todo: move from txt to json
                // todo: model Goal class - status: complete, incomplete
                // todo: show dialog on set button being pressed
                // todo: update stats upon success button being pressed
                // todo: add count up timer -
              },
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _incrementCounter();
          _saveGoal();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccessRoute())
          );
          },
        label: Text('Set'),
        tooltip: 'Set',
        icon: Icon(Icons.adjust)),
    );
  }
}

class SuccessRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Success"),
      ),
      body: Center(
        child: Text('When you have succeeded at your goal click success.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pop(context);
          },
          label: Text('Success'),
          tooltip: 'Success',
          icon: Icon(Icons.adjust)),
    );
  }
}