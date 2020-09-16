import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User(
    this.id,
    this.name,
    this.phone,
    this.email,
    this.country,
    this.avatar_url,
    this.referral_points,
    this.created_at,
    this.updated_at,
  );

  int id;
  String name;
  String phone;
  String email;
  String country;
  String avatar_url;
  String referral_points;
  String created_at;
  String updated_at;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
