import 'dart:convert';

class OfflineEnqueueItem {
  final String type;
  String status;
  final dynamic data;

  OfflineEnqueueItem({
    required this.type,
    required this.status,
    this.data,
  });

  factory OfflineEnqueueItem.fromJson(Map<String, dynamic> json) => OfflineEnqueueItem(
    type: json["type"],
    status: json["status"],
    data: json["data"],
  );
  
  factory OfflineEnqueueItem.fromString(String string) => OfflineEnqueueItem(
    type: string.split(",")
        .firstWhere((string) => string.replaceAll("{", "").startsWith("type"))
        .split(":").last
        .trim().replaceAll("}", ""),
    status: string.split(",").firstWhere((string) => string.startsWith("status")).split(":").last.trim().replaceAll("}", ""),
    data: json.decode(string.split(",").firstWhere((string) => string.startsWith("data")).split(":").last.trim().replaceAll("}", "")),
  );

  Map<String, String> toJson() => {
    "type": type,
    "status": status,
    "data": json.encode(data),
  };

  @override
  String toString() {
    String dataJson = json.encode(data);
    return '{type: $type, status: $status, data: $dataJson}';
  }
}