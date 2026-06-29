import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class MapConst {
  /// Bishkek — Gorky area default coordinates.
  static const LatLng defaultLocation = LatLng(42.8746, 74.6122);

  static const double defaultZoom = 15;

  static const String defaultAddress = 'Горький 1';
}
