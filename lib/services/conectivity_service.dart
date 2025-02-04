import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  void startListening(void Function(List<ConnectivityResult>) onChange) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      onChange(results); // Pass the list of results
    });
  }

  void stopListening() {
    _subscription.cancel();
  }
}
