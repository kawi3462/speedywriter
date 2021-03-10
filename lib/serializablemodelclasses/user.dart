import 'package:json_annotation/json_annotation.dart';
import 'package:speedywriter/serializablemodelclasses/image.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  User(
    this.id,
    this.name,
    this.country,
    this.phone_number,
    this.email,
    this.api_token,
    this.created_at,
    this.updated_at,
    this.image,
  );

  int id;
  String name;
  String country;
  String phone_number;
  String email;
  String api_token;
  String created_at;
  String updated_at;
  Image image;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}


