// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Earning _$EarningFromJson(Map<String, dynamic> json) {
  return Earning(
    json['id'] as int,
    json['details'] as String,
    (json['paidin'] as num)?.toDouble(),
    (json['paidout'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$EarningToJson(Earning instance) => <String, dynamic>{
      'id': instance.id,
      'details': instance.details,
      'paidin': instance.paidin,
      'paidout': instance.paidout,
    };
