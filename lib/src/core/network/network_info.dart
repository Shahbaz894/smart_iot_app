import 'package:connectivity_plus/connectivity_plus.dart';

abstract class INetworkInfo {
  Future<bool> get isConnected;
  // Updated to return a List as required by the new API
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;
  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    // In the new API, "none" is usually part of a list if disconnected
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;
}