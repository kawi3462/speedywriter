import 'package:json_annotation/json_annotation.dart';

part 'referral.g.dart';

@JsonSerializable()
class Referral {
  int id;
  String name;
  String country;
  String email;
  String phone;
  String status;

  Referral(
      this.id, this.name, this.country, this.email, this.phone, this.status);



  factory Referral.fromJson(Map<String, dynamic> json) => _$ReferralFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralToJson(this);
}
