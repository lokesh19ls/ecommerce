import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/connectivity_service.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isConnected)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'No internet connection. Some features may be limited.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isConnected = true; // Hide banner temporarily
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
