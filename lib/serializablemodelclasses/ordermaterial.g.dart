// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordermaterial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ordermaterial _$OrdermaterialFromJson(Map<String, dynamic> json) {
  return Ordermaterial(
    json['id'] as int,
    json['order_id'] as String,
    json['filename'] as String,
    json['original_filename'] as String,
    json['email'] as String,
    json['created_at'] as String,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$OrdermaterialToJson(Ordermaterial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.order_id,
      'filename': instance.filename,
      'original_filename': instance.original_filename,
      'email': instance.email,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };
