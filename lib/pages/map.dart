import 'package:dcs_kneeboard/main.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<MapPage> {
  String msg = "initial text";
  
  @override
  void initState() {
    super.initState();
    App.logger.i("Map page is loaded!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Map Page"),
            Text("Message: $msg"),
          ],
        ),
      ),
    );
  }
}