import 'package:json_annotation/json_annotation.dart';

/// Represents a Department onboard the boat
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Department {
  String departmentName;

  Department({required this.departmentName});

}