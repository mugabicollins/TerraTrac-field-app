import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:terrapipe/widgets/custom_appbar.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());

  List<LatLng> shapePoints = [];
  List<Polygon> drawnPolygons = [];
  Color selectedColor = Colors.blue;
  bool isDrawing = false;
  int geoIdCounter = 1;
  bool isDrawingCircle = false;
  LatLng? circleCenter;
  double radius = 100.0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    loadLocation();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  Future<void> loadLocation() async {
    await controller.getLocation();
  }

  void _onRadiusChanged(double value) {
    setState(() {
      radius = value;
    });
  }

  void _startDrawingCircle() {
    setState(() {
      isDrawing = false;
      isDrawingCircle = true;
    });
  }

  void _clearShapes() {
    setState(() {
      shapePoints.clear();
      drawnPolygons.clear();
      isDrawing = false;
      isDrawingCircle = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        appBar: CustomAppBar(),
        floatingActionButton: isDrawing
            ? const SizedBox()
            : FloatingActionBubble(
          items: [
            Bubble(
              title: "Circle",
              titleStyle:
              const TextStyle(fontSize: 14, color: Colors.white),
              iconColor: Colors.white,
              bubbleColor: Colors.green,
              icon: Icons.circle_outlined,
              onPress: _startDrawingCircle,
            ),
            Bubble(
              title: "Delete",
              titleStyle:
              const TextStyle(fontSize: 14, color: Colors.white),
              iconColor: Colors.white,
              bubbleColor: Colors.red,
              icon: Icons.delete_outline,
              onPress: _clearShapes,
            ),
          ],
          animation: _animation,
          onPress: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          },
          iconData: Icons.add,
          iconColor: Colors.blue,
          backGroundColor: Colors.white,
        ),
        body: controller.locationFetched.isTrue
            ? Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: controller.cameraPosition.value ?? const LatLng(51.5, -0.09),
                initialZoom: 20.0,
                onTap: (_, LatLng point) {
                  if (isDrawingCircle) {
                    setState(() {
                      circleCenter = point;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolygonLayer(
                  polygons: drawnPolygons,
                ),
                CircleLayer(
                  circles: [
                    if (isDrawingCircle && circleCenter != null)
                      CircleMarker(
                        point: circleCenter!,
                        color: Colors.blue.withOpacity(0.5),
                        radius: radius,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (isDrawingCircle && circleCenter != null)
                      Marker(
                        point: circleCenter!,
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (isDrawingCircle)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Adjust Circle Radius (in meters)'),
                      Slider(
                        value: radius,
                        min: 10.0,
                        max: 500.0,
                        onChanged: _onRadiusChanged,
                      ),
                      Text('Radius: ${radius.toStringAsFixed(0)} m'),
                    ],
                  ),
                ),
              ),
          ],
        )
            : const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
