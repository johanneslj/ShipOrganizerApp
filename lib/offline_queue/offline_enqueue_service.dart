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

  addToQueue(Map<String, dynamic> model) async {
    _queue.add(model);
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
  }

  void _storeQueueAndStopService() {
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
    _serviceRunning = false;
  }

  Future<List<dynamic>> _updateQueueFromStorage() {
    return _storage
      .read(key: "OFFLINE_QUEUE")
      .then((string) => string != null ? _queue = _queueFromString(string) : []);
  }

  Future<bool> _isOfflineOrServiceAlreadyRunning() async {
    await _apiService
        .testConnection()
        .then((value) => value != 200 ? _isOffline = true : _isOffline = false);
    if (_isOffline || _serviceRunning) {
      return true;
    }
    return false;
  }

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

  _processItem(Map<String, dynamic> model) async {
    switch (model["type"]) {
      case "UPDATE_STOCK":
        _updateStockOffline(model);
        break;
    }
  }

  void _updateStockOffline(Map<String, dynamic> model) {
    Map<String, dynamic> data = model["data"];
    _apiService.updateStock(
        data["productNumber"],
        data["username"],
        data["quantity"],
        data["latitude"],
        data["longitude"]);
  }

  List<Map<String, dynamic>> _getPendingItems() =>
      _queue.where((item) => item["status"] == "PENDING").toList();

  List<Map<String,dynamic>> _queueFromString(String string) {
    return List<Map<String, dynamic>>.from(json.decode(string));
  }

  String _queueToString(List<Map<String, dynamic>> queue) {
    return json.encode(queue);
  }
}
