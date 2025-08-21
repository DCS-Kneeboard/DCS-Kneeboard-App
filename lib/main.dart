import 'package:dcs_kneeboard/network_manager.dart';
import 'package:dcs_kneeboard/pages/checklist.dart';
import 'package:dcs_kneeboard/pages/map.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() async {
  runApp(App());
}

class App extends StatefulWidget {
  static final logger = Logger();

  const App({super.key});

  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<App> {
  late final Widget mapPage;
  late final Widget checklistPage;

  late Widget activePage;

  @override
  void initState() {
    super.initState();
    mapPage = MapPage();
    checklistPage = ChecklistPage();

    activePage = mapPage;

    NetworkManager.handshake();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: activePage,
        bottomNavigationBar: BottomAppBar(
          child: Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){ setState(() { activePage = mapPage; }); }, child: Text("Map")),
              ElevatedButton(onPressed: (){ setState(() { activePage = checklistPage; }); }, child: Text("Checklist"))
            ],
          )),
        ),
      )
    );
  }
}