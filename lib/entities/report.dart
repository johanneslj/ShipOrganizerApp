import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Report {
  String? name;
  int? quantity;
  double? latitude;
  double? longitude;
  DateTime? registrationDate;
  String? userName;

  Report(
      {this.name,
       this.quantity,
       this.latitude,
       this.longitude,
       this.registrationDate,
      this.userName});

  void setName(String name) {
    this.name = name;
  }

  void setQuantity(int quantity) {
    this.quantity = quantity;
  }

  void setLatitude(double latitude) {
    this.latitude = latitude;
  }

  void setLongitude(double longitude) {
    this.longitude = longitude;
  }

  void setDate(DateTime date) {
    registrationDate = date;
  }

  void setUserName(String userName) {
    this.userName = userName;
  }
}
