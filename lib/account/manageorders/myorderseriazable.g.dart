// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myorderseriazable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Myorder _$MyorderFromJson(Map<String, dynamic> json) {
  return Myorder(
    json['id'] as int,
    json['topic'] as String,
    json['subject'] as String,
    json['pages'] as String,
    json['style'] as String,
    json['document'] as String,
    json['academiclevel'] as String,
    json['langstyle'] as String,
    json['urgency'] as String,
    json['spacing'] as String,
    json['total'] as String,
    json['description'] as String,
    json['status'] as String,
    json['payment'] as String,
    json['created_at'] as String,
  )..materials = (json['materials'] as List)
      ?.map((e) => e == null ? null : Image.fromJson(e as Map<String, dynamic>))
      ?.toList();
}

Map<String, dynamic> _$MyorderToJson(Myorder instance) => <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'subject': instance.subject,
      'pages': instance.pages,
      'style': instance.style,
      'document': instance.document,
      'academiclevel': instance.academiclevel,
      'langstyle': instance.langstyle,
      'urgency': instance.urgency,
      'spacing': instance.spacing,
      'total': instance.total,
      'description': instance.description,
      'status': instance.status,
      'payment': instance.payment,
      'created_at': instance.created_at,
      'materials': instance.materials,
    };
