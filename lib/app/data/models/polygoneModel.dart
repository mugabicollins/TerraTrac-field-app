class PolygonModel {
  final int id;
  final String polygonData;
  final DateTime timestamp;
  final String userEmail;
  final String phoneNumber;
  final String deviceId;

  PolygonModel({
    required this.id,
    required this.polygonData,
    required this.timestamp,
    required this.userEmail,
    required this.phoneNumber,
    required this.deviceId,
  });

  /// Convert JSON Map to Model
  factory PolygonModel.fromJson(Map<String, dynamic> json) {
    return PolygonModel(
      id: json['id'],
      polygonData: json['polygon_data'],
      timestamp: DateTime.parse(json['timestamp']),
      userEmail: json['user_email'],
      phoneNumber: json['phone_number'],
      deviceId: json['device_id'],
    );
  }

  /// Convert Model to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'polygon_data': polygonData,
      'timestamp': timestamp.toIso8601String(),
      'user_email': userEmail,
      'phone_number': phoneNumber,
      'device_id': deviceId,
    };
  }
}
