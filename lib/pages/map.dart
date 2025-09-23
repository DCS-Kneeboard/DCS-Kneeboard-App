
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
    TerrainProjection terrain = SinaiProjection();

    NetworkManager.onUpdate.listen((state) {
      setState((() {
        final point = terrain.simToLatLon(state.x, state.z);
        _position = Position(point.x, point.y);
      }));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        options: MapOptions(
          initStyle: "https://tiles.openfreemap.org/styles/liberty"
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        children: [
          MapCompass(hideIfRotatedNorth: true,),
          WidgetLayer(
            markers: [
              Marker(point: _position, size: Size.square(20), child: CircleAvatar(backgroundColor: Colors.deepOrange))
            ]
          )
        ],
      )
    );
  }
}