import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  SharedPreference._privateConstructor();
  static final SharedPreference instance =
      SharedPreference._privateConstructor();

  Future<void> saveEmail(String input) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', input);
  }

  Future<String?> getString() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> savePiplineAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('piplineAccessToken', token);
  }

    Future<void> savePiplineRefreshToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('piplineRefreshToken', token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<String> getPiplineRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('piplineRefreshToken') ?? '';
  }

  Future<String> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken') ?? '';
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<String> getPiplineToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('piplineAccessToken') ?? '';
  }

  Future clearLocalData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveSecretKeys(String apiKey, String clientSecret) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('api_key', apiKey);
    await prefs.setString('client_secret', clientSecret);
  }

  Future<String?> getSecretKeyLocalDb(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
