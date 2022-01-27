import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Department {
  String departmentName;

  Department({required this.departmentName});

}