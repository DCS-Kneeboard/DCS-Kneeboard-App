import 'package:proj4dart/proj4dart.dart';

abstract class TerrainProjection {
  abstract final double centralMeridian;
  abstract final double falseEasting;
  abstract final double falseNorthing;
  abstract final double scaleFactor;

  Point simToLatLon(double simX, double simZ) {
    var def = [
      "+proj=tmerc",
      "+lat_0=0",
      "+lon_0=$centralMeridian",
      "+k_0=$scaleFactor",
      "+x_0=$falseEasting",
      "+y_0=$falseNorthing",
      "+towgs84=0,0,0,0,0,0,0",
      "+units=m",
      "+vunits=m",
      "+ellps=WGS84",
      "+no_defs",
      "+axis=neu",
    ].join(" ");

    var projection = Projection.parse(def);
    final wgs84 = Projection.WGS84;
    final pointSim = Point(x: simX, y: simZ);
    return projection.transform(wgs84, pointSim);
  }
}

class SinaiProjection extends TerrainProjection {
  @override
  final double centralMeridian = 33.0;
  @override
  final double falseEasting = 169221.9999999585;
  @override
  final double falseNorthing = -3325312.9999999693;
  @override
  final double scaleFactor = 0.9996;
}

class CaucausesProjection extends TerrainProjection {
  @override
  final double centralMeridian = 33.0;
  @override
  final double falseEasting = -99516.9999999732;
  @override
  final double falseNorthing = -4998114.999999984;
  @override
  final double scaleFactor = 0.9996;
}