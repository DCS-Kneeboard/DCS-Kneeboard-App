import 'package:dcs_kneeboard/network_manager.dart';
import 'package:dcs_kneeboard/pages/checklist.dart';
import 'package:dcs_kneeboard/pages/map.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(App());
  NetworkManager.handshake();

  // final info = NetworkInfo();
  // String? ip = await info.getWifiIP(); // e.g., 10.100.102.50
  // String? subnet = ip?.substring(0, ip.lastIndexOf('.')); // 10.100.102
  // String broadcast = '$subnet.255'; // 10.100.102.255

  // final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 45931);
  // socket.broadcastEnabled = true;
  // debugPrint("UDP socket is bound to ${socket.address.address}:${socket.port}");
  
  // socket.send(utf8.encode(ip!), InternetAddress(broadcast), socket.port);

  // socket.listen((event) {
  //     if (event == RawSocketEvent.read) {
  //       Datagram? datagram;
  //       while ((datagram = socket.receive()) != null) {
  //         final msg = utf8.decode(datagram!.data);
  //         debugPrint("Received message: $msg");
  //       }
  //     }
  //   });

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