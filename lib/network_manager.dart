import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dcs_kneeboard/config.dart';
import 'package:dcs_kneeboard/game_state.dart';
import 'package:dcs_kneeboard/main.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkManager {
  static RawDatagramSocket? socket;

  static final StreamController<GameState> _updateController = StreamController.broadcast();
  static Stream<GameState> get onUpdate => _updateController.stream;

  static void handshake() async {
    String? broadcast = await _getBroadcast();
    App.logger.i(broadcast);
    if (broadcast == null) {
      // TODO: display error message
      throw Exception("Could not get broadcast IP address!");
    }
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, Config.port);
    socket!.broadcastEnabled = true;
    String msg = Config.messageIdSend;

    bool connected = false;
    App.logger.i("Performing handshake");
    while (!connected) {
      socket!.send(
        utf8.encode(msg),
        InternetAddress(broadcast),
        Config.port
      );

      final start = DateTime.now();
      while (DateTime.now().difference(start).inMilliseconds < 200) {
        Datagram? datagram = socket!.receive();
        if (datagram != null) {
          final message = utf8.decode(datagram.data);
          if (message == Config.messageIdRecv) {
            App.logger.i("Established connection with DCS!\nDCS IP is ${datagram.address.address}");
            socket!.close();
            socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, Config.port);
            socket!.listen(_startListening);
            connected = true;
            break;
          }
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }

  static void dispose() {
    socket!.close();
  }

  static void _startListening(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    
    final datagram = socket!.receive();
    if (datagram == null) return;

    final packet = utf8.decode(datagram.data);
    final data = jsonDecode(packet);
    final positionData = data["Position"];
    final state = GameState(
      x: positionData["x"],
      z: positionData["z"],
      alt: data["Altitude"],
      groundSpeed: data["GroundSpeed"],
      trueHeading: data["TrueHeading"]
    );
    _updateController.add(state);
  }

  static Future<String?> _getBroadcast() async {
    final info = NetworkInfo();
    String? ip = await _getIP();
    String? subnetMask = await info.getWifiSubmask();
    if (ip == null || subnetMask == null) return null;

    List<int> ipParts = ip.split('.').map(int.parse).toList();
    List<int> maskParts = subnetMask.split('.').map(int.parse).toList();

    List<int> broadcastParts = List.generate(4, (i) => ipParts[i] | (~maskParts[i] & 0xFF));

    return broadcastParts.join('.');
  }

  static Future<String?> _getIP() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }
}