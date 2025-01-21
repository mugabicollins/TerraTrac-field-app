import 'package:geodesy/geodesy.dart';

class WalkTrackingModel {
  int? geoId;
  List<LatLng>? polylinePoint;

  
  WalkTrackingModel(this.geoId, this.polylinePoint);

  WalkTrackingModel.fromJson(Map<String, dynamic> json)
      : geoId = json['id'],
        polylinePoint = json['polylinePoint'];

  Map<String, dynamic> toJson() => {
        'id': geoId,
        'polylinePoint': polylinePoint,
      };
}
