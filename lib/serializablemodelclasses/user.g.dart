// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['id'] as int,
    json['name'] as String,
    json['phone'] as String,
    json['email'] as String,
    json['country'] as String,
    json['avatar_url'] as String,
    json['referral_points'] as String,
    json['created_at'] as String,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'country': instance.country,
      'avatar_url': instance.avatar_url,
      'referral_points': instance.referral_points,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };
