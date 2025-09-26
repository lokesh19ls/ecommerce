import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    // Check initial connectivity status
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasConnected = _isConnected;
    _isConnected = result.any((connectivity) => 
      connectivity != ConnectivityResult.none);
    
    // Only emit if status changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
    }
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((connectivity) => connectivity != ConnectivityResult.none);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
