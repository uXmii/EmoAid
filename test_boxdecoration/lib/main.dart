import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
