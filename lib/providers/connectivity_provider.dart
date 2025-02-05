import 'package:flutter/material.dart';
import '../services/network_service.dart';

class ConnectivityProvider with ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  bool _isOnline = true;

  ConnectivityProvider() {
    _networkService.networkStatusStream.listen((status) {
      _isOnline = status;
      notifyListeners();
    });
  }

  bool get isOnline => _isOnline;
}
