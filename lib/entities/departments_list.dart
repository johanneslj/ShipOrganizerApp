import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DepartmentsList {
  Map departmentName;
  int rights;

  DepartmentsList({required this.departmentName, required this.rights});

}