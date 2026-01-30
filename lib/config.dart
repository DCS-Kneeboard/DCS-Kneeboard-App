import 'package:dcs_kneeboard/projection.dart';

class Config {
  static const port = 45931;
  static const messageIdSend = "DCS_KNBRD19283_PH";
  static const messageIdRecv = "DCS_KNBRD19283_PC";
  static TerrainProjection terrain = CaucausesProjection();
  static const meterToFeet = 3.28084;
  static const mpsToKts = 1.94384;
}