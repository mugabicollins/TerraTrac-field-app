import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:terrapipe/app/data/repositories/terratrac_db.dart';
import 'package:terrapipe/app/modules/splash/splash_binding.dart';
import 'package:terrapipe/routes/app_pages.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready before database initialization
  // Initialize the database
  await TerraTracDataBaseHelper.dbInstance.database;
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      getPages: AppPages.pages,
      initialRoute: '/splash',
      initialBinding: SplashBinding(),

    );
  }
}
