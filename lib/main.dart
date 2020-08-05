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

  Future<int> countSuccess() async {
    int countSuccess = 0;
    try{
      final file = await _localFile;
      var lines = await file.readAsLines();
      for(int i = 0; i<lines.length; i++){
        if(lines[i].contains("success")){
          countSuccess++;
        }
      }
      print("$countSuccess countSuccess");
      return countSuccess;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$counter', mode:FileMode.append);
  }
  
  Future<File> writeText(String text) async {
    final file = await _localFile;
    print("input text $text");
    if(text == "deleteme"){
      return file.writeAsString('', flush: true);
    }
    else
      {
        return file.writeAsString('$text', mode:FileMode.append);
      }
    // Write the file

  }



  Future<void> appendSuccessStatus() async {
    final file = await _localFile;
    // Write the file
    return file.writeAsStringSync('success', mode: FileMode.append);
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          goalStats(),
          TextField(
            decoration: new InputDecoration(
              border: new OutlineInputBorder(
//                borderSide: new BorderSide(color: Colors.teal),
              ),
            ),
            textInputAction: TextInputAction.done,
            maxLines: null,
            controller: _controller,
            onSubmitted: (String value) async {

              // todo: move from txt to json
              // todo: model Goal class - status: complete, incomplete
              // todo: update stats upon success button being pressed
              // todo: count time since goal set on success page
              // todo: determine how to do a module
            },
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {

          });
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



class goalStats extends StatelessWidget {
  const goalStats({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<int> SuccessCount = new CounterStorage().countSuccess();
    String successCount = SuccessCount.toString();
    return Text(
      "$successCount successes completed!",
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
//            var successCounter = new CounterStorage().countSuccess();

            Navigator.pop(context);
            new CounterStorage().writeText("success\n");
          },
          label: Text('Success'),
          tooltip: 'Success',
          icon: Icon(Icons.adjust)),
    );
  }
}




