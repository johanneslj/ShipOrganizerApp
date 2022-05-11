import 'package:json_annotation/json_annotation.dart';
/// Represents a simple User
/// The user has an Id, name, email and a list of departments they
/// have access to.
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
