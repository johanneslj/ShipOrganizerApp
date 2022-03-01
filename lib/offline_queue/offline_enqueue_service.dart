import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';

import 'offline_enqueue_item.dart';

class OfflineEnqueueService {

  static final OfflineEnqueueService _service = OfflineEnqueueService._internal();

  factory OfflineEnqueueService() {
    return _service;
  }

  OfflineEnqueueService._internal();

  bool _serviceRunning = false;

  ApiService apiService = ApiService();

  bool _isOffline = false;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<OfflineEnqueueItem> _queue = [];

  startService() async {
    // TODO Remove print
    print("OFFLINE SERVICE STARTED");

    // Check if server is UP
    apiService
        .testConnection()
        .then((value) => value != 200 ? _isOffline = true : _isOffline = false);

    // Service is already running
    if (_serviceRunning == true) return;

    // Should be online to process the queue
    if (_isOffline == true) return;

    _serviceRunning = true;

    _storage
        .read(key: "OFFLINE_QUEUE")
        .then((string) => string != null ? _queue = _queueFromString(string) : []);

    // Search all the pending items in the queue
    List<OfflineEnqueueItem> pendingItems =
        _queue.where((item) => item.status == "PENDING").toList();

    // If the queue doesn't have any items the service is stopped
    if (pendingItems.isEmpty) return;

    for (OfflineEnqueueItem item in pendingItems) {
      try {
        // Mark enqueue item with the status PROCESSING
        item.status = "PROCESSING";

        // Process enqueue item
        await _processItem(item);

        // Mark enqueue item with the status DONE
        item.status = "DONE";

      } catch (ex) {
         item.status = "ERROR:" + ex.toString();
      }
    }
    _storage.write(key: "OFFLINE_QUEUE", value: _queueToString(_queue));
    _serviceRunning = false;
    startService();
  }

  addToQueue(OfflineEnqueueItem model) async {
    _queue.add(model);
    startService();
  }

  _processItem(OfflineEnqueueItem model) async {
    switch (model.type) {
      case "UPDATE_STOCK":
        String productNumber = model.data["productNumber"];
        String username = model.data["username"];
        int amount = model.data["amount"];
        double latitude = model.data["latitude"];
        double longitude = model.data["longitude"];
        // TODO Remove print
        print("PROCESSING ITEM: " + model.data);
        apiService.updateStock(productNumber, username, amount, latitude, longitude);
        break;
      // More implementations can be added here.
    }
  }

  List<OfflineEnqueueItem> _queueFromString(String string) {
    List<OfflineEnqueueItem> queue = [];

    List<String> strings = string.split(",");
    for (String string in strings) {
      queue.add(OfflineEnqueueItem.fromString(string));
    }
    return queue;
  }

  String _queueToString(List<OfflineEnqueueItem> queue) {
    String string = "";

    for (OfflineEnqueueItem item in queue) {
      string += item.toString() + ",";
    }

    return string;
  }
}
