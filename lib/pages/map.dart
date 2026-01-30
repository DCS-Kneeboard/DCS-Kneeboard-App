import 'dart:math';

import 'package:dcs_kneeboard/config.dart';
import 'package:dcs_kneeboard/gravitational_model.dart';
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
  double _altitude = 0;
  double _groundSpeed = 0;
  double _trueHeading = 0;
  double _magVar =  	5.95;
  MapController? _mapController;
  GravitationalModel? _gm;
  bool _followAircraft = true;
  
  @override
  void initState() {
    super.initState();

    GravitationalModel.loadFromAsset("assets/egm96-15.pgm").then((loadedGrid) {
      setState(() {
        _gm = loadedGrid;
        App.logger.i("Finished loading gravitational data!");
      });
    }).catchError((e) {
      App.logger.e(e);
    });

    App.logger.i("Map page is loaded!");
    TerrainProjection terrain = Config.terrain;

    NetworkManager.onUpdate.listen((state) {
      setState((() {
        final point = terrain.simToLatLon(state.x, state.z);
        _position = Position(point.x, point.y);

        if (_gm != null) {
          _altitude = _gm!.getHAEMeters(point.x, point.y, state.alt) * Config.meterToFeet;
        }
        _groundSpeed = state.groundSpeed * Config.mpsToKts;
        _trueHeading = state.trueHeading; 
        
        if (_followAircraft) {
          _mapController?.moveCamera(center: _position);
        }
      }));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = MapLibreMap(
      options: MapOptions(
        initStyle: "https://tiles.openfreemap.org/styles/liberty",
        gestures: MapGestures(rotate: false, pan: true, zoom: true, pitch: false)
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onEvent: (event) {
        if (event is MapEventStartMoveCamera) {
          if (event.reason != CameraChangeReason.apiGesture) return;
          _followAircraft = false;
        }
      },
      children: [
        WidgetLayer(
          markers: [
            Marker(point: _position, size: Size.square(20), child: CircleAvatar(backgroundColor: Colors.deepOrange))
          ]
        )
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        map,
        Positioned(
          bottom: 20,
          left: 20,
          child: ElevatedButton(onPressed: () {_followAircraft = true;}, child: Text("f")),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${_groundSpeed.round()} kts"),
              Text("${_altitude.round()} ft"),
              Text("${_trueHeading.round()}°/${(_trueHeading-_magVar).round()}°M"),
            ],
          )
        )
      ],
    );
  }
}