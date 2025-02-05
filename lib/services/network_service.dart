import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _networkStatusController = StreamController<bool>.broadcast();

  NetworkService() {
    _checkConnectivity(); // Initial Check
    _connectivity.onConnectivityChanged.listen((result) {
      _networkStatusController.add(_isConnected(result as ConnectivityResult));
    });
  }

  /// Stream to listen for connectivity changes
  Stream<bool> get networkStatusStream => _networkStatusController.stream;

  /// Check connectivity once at the beginning
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _networkStatusController.add(_isConnected(result as ConnectivityResult));
  }

  /// Helper function to determine connectivity status
  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _networkStatusController.close();
  }
}
