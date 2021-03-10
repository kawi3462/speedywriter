import 'package:json_annotation/json_annotation.dart';

part 'earning.g.dart';

@JsonSerializable()
class Earning {
  int id;
  String details;
  double paidin;
  double paidout;

  Earning(
    this.id,
    this.details,
    this.paidin,
    this.paidout
  );

  factory Earning.fromJson(Map<String, dynamic> json) =>
      _$EarningFromJson(json);

  Map<String, dynamic> toJson() => _$EarningToJson(this);
}
