import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'dart:convert';


import 'offline_enqueue_item.dart';

class OfflineEnqueueService {

  static final OfflineEnqueueService _service = OfflineEnqueueService._internal();

  factory OfflineEnqueueService() {
    return _service;
  }

  OfflineEnqueueService._internal();

  bool _serviceRunning = false;

  ApiService apiService = ApiService.getInstance();

  bool _isOffline = false;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static List<Map<String, dynamic>> _queue = [];

  startService() async {
    // Check if server is UP
    await apiService
        .testConnection()
        .then((value) => value != 200 ? _isOffline = true : _isOffline = false);

    // Service is already running
    if (_serviceRunning) return;
    // Should be online to process the queue
    if (_isOffline) return;

    _serviceRunning = true;

    await _storage
        .read(key: "OFFLINE_QUEUE")
        .then((string) => string != null ? _queue = _queueFromString(string) : []);

    // Search all the pending items in the queue
    List<dynamic> pendingItems =
        _queue.where((item) => item["status"] == "PENDING").toList();

    // If the queue doesn't have any items the service is stopped
    if (pendingItems.isEmpty){
      _serviceRunning = false;
      return;
    }

    for (Map<String, dynamic> item in pendingItems) {
      try {
        // Mark enqueue item with the status PROCESSING
        item["status"] = "PROCESSING";

        // Process enqueue item
        await _processItem(item);

        // Mark enqueue item with the status DONE
        item["status"] = "DONE";

      } catch (ex) {
         item["status"] = "ERROR:" + ex.toString();
      }
    }
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
    _serviceRunning = false;
  }

  addToQueue(Map<String, dynamic> model) async {
    _queue.add(model);
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
    // startService();
  }

  _processItem(Map<String, dynamic> model) async {
    switch (model["type"]) {
      case "UPDATE_STOCK":
        updateStockOffline(model);
        break;
      // More implementations can be added here.
    }
  }

  void updateStockOffline(Map<String, dynamic> model) {
    Map<String, dynamic> data = model["data"];

    String productNumber = data["productNumber"];
    String username = data["username"];
    int amount = data["quantity"];
    double latitude = data["latitude"];
    double longitude = data["longitude"];

    apiService.updateStock(productNumber, username, amount, latitude, longitude);
  }

  List<Map<String,dynamic>> _queueFromString(String string) {
    return List<Map<String, dynamic>>.from(json.decode(string));
  }

  String _queueToString(List<Map<String, dynamic>> queue) {
    return json.encode(queue);
  }
}
