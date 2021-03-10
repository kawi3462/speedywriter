// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Referral _$ReferralFromJson(Map<String, dynamic> json) {
  return Referral(
    json['id'] as int,
    json['name'] as String,
    json['country'] as String,
    json['email'] as String,
    json['phone'] as String,
    json['status'] as String,
  );
}

Map<String, dynamic> _$ReferralToJson(Referral instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'email': instance.email,
      'phone': instance.phone,
      'status': instance.status,
    };
