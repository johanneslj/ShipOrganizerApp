import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Department {
  String departmentName;
  int rights;

  Department({required this.departmentName, required this.rights});

}