import 'package:json_annotation/json_annotation.dart';
import 'package:ship_organizer_app/entities/department.dart';

/// Represents a simple User
///
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class User {
  int? id;
  String? name;
  String? email;
  List<String> departments;

  User({required this.name, required this.email, required this.departments});


  String getName() {
    return name!;
  }

  String getEmail() {
    return email!;
  }
}
