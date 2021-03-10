// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['id'] as int,
    json['name'] as String,
    json['country'] as String,
    json['phone_number'] as String,
    json['email'] as String,
    json['api_token'] as String,
    json['created_at'] as String,
    json['updated_at'] as String,
    json['image'] == null
        ? null
        : Image.fromJson(json['image'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'phone_number': instance.phone_number,
      'email': instance.email,
      'api_token': instance.api_token,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'image': instance.image?.toJson(),
    };
