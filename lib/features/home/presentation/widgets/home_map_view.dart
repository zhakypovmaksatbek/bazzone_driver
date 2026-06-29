import 'package:bazzone_driver/core/constants/map_const.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMapView extends StatelessWidget {
  const HomeMapView({
    super.key,
    required this.currentPosition,
    required this.bottomPadding,
    this.onMapCreated,
  });

  final LatLng currentPosition;
  final double bottomPadding;
  final ValueChanged<GoogleMapController>? onMapCreated;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: currentPosition,
        zoom: MapConst.defaultZoom,
      ),
      onMapCreated: onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      padding: EdgeInsets.only(top: 88, bottom: bottomPadding, right: 16),
    );
  }
}
