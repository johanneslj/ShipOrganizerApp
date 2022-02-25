import 'package:json_annotation/json_annotation.dart';

/// Represents a simple User
///
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class User {
  String? name;
  String? email;

  User({required this.name, required this.email});


  String getName() {
    return name!;
  }

  String getEmail() {
    return email!;
  }
}
