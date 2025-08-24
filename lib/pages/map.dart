
import 'package:dcs_kneeboard/projection.dart';
import 'package:dcs_kneeboard/main.dart';
import 'package:dcs_kneeboard/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<MapPage> {
  Position _position = Position(0, 0);
  MapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    App.logger.i("Map page is loaded!");

    NetworkManager.onUpdate.listen((state) {
      setState((() {
        final point = SinaiProjection.simToLatLon(state.x, state.z);
        _position = Position(point.x, point.y);
        App.logger.i("x: ${state.x} z: ${state.z}");
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        options: MapOptions(
          initStyle: "https://tiles.openfreemap.org/styles/liberty"
        ),
        children: [
          MapCompass(hideIfRotatedNorth: true,),
          WidgetLayer(
            markers: [
              Marker(
                point: _position,
                size: Size.square(50),
                child: CircleAvatar(backgroundColor: Color.fromARGB(255, 0, 0, 255))
              )
            ],
          )
        ],
        onMapCreated: (controller) {
          _mapController = controller;
        },
      )
    );
  }
}