
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController= new Location();

  final Completer<GoogleMapController>_mapController =Completer<GoogleMapController>();
  static const LatLng _pGooglePlex = LatLng(12.922637, 77.617447);
  static const LatLng _pApplePark = LatLng(11.341036, 77.717163);
  LatLng? _currentP=null;

  @override
  void initState(){
    super.initState();
    getLocationUpdates();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body:_currentP ==null?const Center(
        child: Text("Loading...."),
      ):
      GoogleMap(
          onMapCreated: (GoogleMapController controller)=>
              _mapController.complete(controller),
        initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 13),
        markers: {
          Marker(
              markerId: MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position:_currentP!),
          Marker(
              markerId: MarkerId("_sourceLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position:_currentP!),
          Marker(
              markerId: MarkerId("_destinationLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pApplePark),
        },
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async{
    final GoogleMapController controller= await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos,zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }
  Future<void> getLocationUpdates()async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled();
    if(_serviceEnabled){
      _serviceEnabled = await _locationController.requestService();
}
    else{
      return;
}
    _permissionGranted = await _locationController.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted= await _locationController.requestPermission();
      if(_permissionGranted!=PermissionStatus.granted){
        return;
}
}
    _locationController.onLocationChanged.listen((LocationData currentlocation) {
      if(currentlocation.latitude!=null&& currentlocation.longitude!=null){
        setState(() {
        _currentP=LatLng(currentlocation.latitude!, currentlocation.longitude!);
       _cameraToPosition(_currentP!);
        });

}

});
}
}