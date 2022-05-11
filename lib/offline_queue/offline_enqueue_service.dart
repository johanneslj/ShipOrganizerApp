import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'dart:convert';

class OfflineEnqueueService {

  OfflineEnqueueService._internal();
  bool _serviceRunning = false;
  bool _isOffline = false;
  final ApiService _apiService = ApiService.getInstance();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static List<Map<String, dynamic>> _queue = [];
  static final OfflineEnqueueService _service = OfflineEnqueueService._internal();

  factory OfflineEnqueueService() {
    return _service;
  }

  /// Starts the offline service if the device is offline
  startService() async {
    if (await _isOfflineOrServiceAlreadyRunning()) {
      return;
    }
    _serviceRunning = true;
    await _updateQueueFromStorage();
    List<Map<String, dynamic>> pendingItems = _getPendingItems();
    if (pendingItems.isEmpty){
      _serviceRunning = false;
      return;
    }
    await _processItems(pendingItems);
    _storeQueueAndStopService();
  }

  /// Adds a network request to the offline queue
  addToQueue(Map<String, dynamic> model) async {
    _queue.add(model);
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
  }

  /// Stores the current queue and stops the service
  void _storeQueueAndStopService() {
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
    _serviceRunning = false;
  }

  /// Updates the queue with whatever is stored in storage
  Future<List<dynamic>> _updateQueueFromStorage() {
    return _storage
      .read(key: "OFFLINE_QUEUE")
      .then((string) => string != null ? _queue = _queueFromString(string) : []);
  }

  /// Checks if the device is offline or if the service is already running
  Future<bool> _isOfflineOrServiceAlreadyRunning() async {
    await _apiService
        .testConnection()
        .then((value) => value != 200 ? _isOffline = true : _isOffline = false);
    if (_isOffline || _serviceRunning) {
      return true;
    }
    return false;
  }

  /// Process the stored network requests
  Future<void> _processItems(List<Map<String, dynamic>> pendingItems) async {
    for (Map<String, dynamic> item in pendingItems) {
      try {
        item["status"] = "PROCESSING";
        await _processItem(item);
        item["status"] = "DONE";
      } catch (ex) {
         item["status"] = "ERROR: " + ex.toString();
      }
    }
  }

  /// Processes the network request
  _processItem(Map<String, dynamic> model) async {
    switch (model["type"]) {
      case "UPDATE_STOCK":
        _updateStockOffline(model);
        break;
    }
  }

  /// Used to update the stock on local inventory
  void _updateStockOffline(Map<String, dynamic> model) {
    Map<String, dynamic> data = model["data"];
    _apiService.updateStock(
        data["productNumber"],
        data["username"],
        data["quantity"],
        data["latitude"],
        data["longitude"]);
  }

  /// Gets any requests that are pending
  List<Map<String, dynamic>> _getPendingItems() =>
      _queue.where((item) => item["status"] == "PENDING").toList();

  /// Decode the queue from ths String it is stored in in local storage
  List<Map<String,dynamic>> _queueFromString(String string) {
    return List<Map<String, dynamic>>.from(json.decode(string));
  }

  /// Json encodes a given String
  String _queueToString(List<Map<String, dynamic>> queue) {
    return json.encode(queue);
  }
}
