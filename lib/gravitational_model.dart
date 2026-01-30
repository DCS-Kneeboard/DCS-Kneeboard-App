import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GravitationalModel {
  final int width;
  final int height;
  final int maxVal;
  final Float64List _data; // Stores decoded height in meters
  
  // Standard EGM96 parameters (Adjust these if your PGM source differs)
  static const double defaultScale = 0.003;
  static const double defaultOffset = -108.0;

  GravitationalModel(this.width, this.height, this.maxVal, this._data);

  /// Factory to load and parse the PGM file from Flutter Assets
  static Future<GravitationalModel> loadFromAsset(String path) async {
    // 1. Load bytes on the main thread (fast)
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();

    // 2. Move heavy parsing to a background Isolate (prevents "holding")
    return await compute(_parseInBackground, bytes);
  }

  static GravitationalModel _parseInBackground(Uint8List bytes) {
    int index = 0;

    // Safer token reader to prevent infinite loops
    String nextToken() {
      var buffer = StringBuffer();
      while (index < bytes.length) {
        int char = bytes[index++];
        if (char <= 32) { // Whitespace or control chars
          if (buffer.isEmpty) continue; // Skip leading whitespace
          break; 
        }
        if (char == 35) { // '#' Comment
          while (index < bytes.length && bytes[index] != 10) { index++; } // Skip to newline
          continue;
        }
        buffer.writeCharCode(char);
      }
      return buffer.toString();
    }

    // 1. Parse Header
    final magic = nextToken();
    if (magic != 'P5') throw Exception("Not a binary PGM");
    
    final width = int.parse(nextToken());
    final height = int.parse(nextToken());
    final maxVal = int.parse(nextToken());

    // 2. Prepare Data
    final totalPixels = width * height;
    final decodedData = Float64List(totalPixels);
    final is16Bit = maxVal > 255;
    
    // The PGM spec says binary data starts immediately after the single 
    // whitespace character following the maxVal.
    final byteView = ByteData.sublistView(bytes, index);

    // 3. Optimized Math Loop
    const double scale = 0.003;
    const double offset = -108.0;

    if (is16Bit) {
      for (int i = 0; i < totalPixels; i++) {
        // Big Endian read
        int p = byteView.getUint16(i * 2, Endian.big);
        decodedData[i] = (p * scale) + offset;
      }
    } else {
      for (int i = 0; i < totalPixels; i++) {
        decodedData[i] = (bytes[index + i] * scale) + offset;
      }
    }

    return GravitationalModel(width, height, maxVal, decodedData);
  }

  /// Get geoid height at specific Lat/Lon using Bilinear Interpolation
  double getHeight(double lat, double lon) {
    // 1. Normalize Lat/Lon
    // EGM96 usually covers: Lat 90 to -90, Lon 0 to 360
    
    // Clamp Latitude
    if (lat > 90) lat = 90;
    if (lat < -90) lat = -90;
    
    // Wrap Longitude (0 to 360)
    while (lon < 0) { lon += 360; }
    while (lon >= 360) { lon -= 360; }

    // 2. Map to Grid Coordinates
    // For a standard 15-minute grid (0.25 degrees):
    // Row 0 is North Pole (+90), Row H-1 is South Pole (-90)
    // Col 0 is Prime Meridian (0), Col W-1 is 359.75
    
    double latStep = 180.0 / (height - 1); 
    double lonStep = 360.0 / width;

    // Grid indices (floating point)
    double y = (90.0 - lat) / latStep;
    double x = lon / lonStep;

    // 3. Bilinear Interpolation
    int x0 = x.floor();
    int y0 = y.floor();
    int x1 = (x0 + 1) % width; // Wrap longitude
    int y1 = min(y0 + 1, height - 1); // Clamp latitude

    // Get values at 4 corners
    double v00 = _getValue(x0, y0);
    double v10 = _getValue(x1, y0);
    double v01 = _getValue(x0, y1);
    double v11 = _getValue(x1, y1);

    // Weights
    double wx = x - x0;
    double wy = y - y0;

    // Interpolate Top and Bottom edges
    double top = v00 * (1 - wx) + v10 * wx;
    double bottom = v01 * (1 - wx) + v11 * wx;

    // Final interpolation
    return top * (1 - wy) + bottom * wy;
  }

  double getHAEMeters(double lat, double lon, double msl) {
    return getHeight(lat, lon) + msl;
  }

  double _getValue(int x, int y) {
    return _data[y * width + x];
  }
}