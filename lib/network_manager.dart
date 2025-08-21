import 'dart:convert';
import 'dart:io';

import 'package:dcs_kneeboard/config.dart';
import 'package:dcs_kneeboard/main.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkManager {
  late final RawDatagramSocket socket;

  NetworkManager._(socket);

  static void handshake() async {
    String? broadcast = await getBroadcast();
    App.logger.i(broadcast);
    if (broadcast == null) {
      // TODO: display error message
      throw Exception("Could not get broadcast IP address!");
    }
    RawDatagramSocket handshakeSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, Config.port);
    handshakeSocket.broadcastEnabled = true;
    String msg = "${Config.messageIdSend}|${(await getIP())!}";
    bool connectedToDCS = false;

    int i = 0;
    App.logger.i("Performing handshake");
    while (!connectedToDCS && i < 10) {
      App.logger.i("Handshake test $i");
      handshakeSocket.send(
        utf8.encode(msg),
        InternetAddress(broadcast),
        Config.port
      );

      final start = DateTime.now();
      while (DateTime.now().difference(start).inMilliseconds < 200) {
        Datagram? datagram = handshakeSocket.receive();
        if (datagram != null) {
          final message = utf8.decode(datagram.data);
          if (message.startsWith(Config.messageIdRecv)) {
            App.logger.i("Established connection with DCS!");
            connectedToDCS = true;
            break;
          }
        }
        await Future.delayed(Duration(milliseconds: 10)); // small yield
      }

      i++;
    }
  }

  static Future<String?> getBroadcast() async {
    final info = NetworkInfo();
    String? ip = await getIP();
    String? subnetMask = await info.getWifiSubmask();
    if (ip == null || subnetMask == null) return null;

    List<int> ipParts = ip.split('.').map(int.parse).toList();
    List<int> maskParts = subnetMask.split('.').map(int.parse).toList();

    List<int> broadcastParts = List.generate(4, (i) => ipParts[i] | (~maskParts[i] & 0xFF));

    return broadcastParts.join('.');
  }

  static Future<String?> getIP() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }
}