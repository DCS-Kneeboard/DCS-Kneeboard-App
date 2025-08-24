import 'package:proj4dart/proj4dart.dart';

class SinaiProjection {
  static const double centralMeridian = 33.0;
  static const double falseEasting = 169221.9999999585;
  static const double falseNorthing = -3325312.9999999693;
  static const double scaleFactor = 0.9996;

  static Point simToLatLon(double simX, double simZ) {
    var def = "+proj=tmerc+lat_0=0+lon_0=$centralMeridian+k_0=$scaleFactor+x_0=$falseEasting+y_0=$falseNorthing+towgs84=0,0,0,0,0,0,0+units=m+vunits=m+ellps=WGS84+no_defs+axis=neu";
    var projection = Projection.parse(def);
    final wgs84 = Projection.WGS84;
    final pointSim = Point(x: simX, y: simZ);
    return projection.transform(wgs84, pointSim);
  }
}