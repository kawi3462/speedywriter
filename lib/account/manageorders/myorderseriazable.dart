import 'package:json_annotation/json_annotation.dart';


part 'myorderseriazable.g.dart';

@JsonSerializable()

class Myorder{
  Myorder(
    this.id,
  this.email,
  this.topic,
  this.subject,
  this.pages,
  this.style,
  this.document,
  this.academiclevel,
  this.langstyle,
  this.	urgency,
  this.spacing,
  this.total,
  this.description,
  this.status,
  this.payment,
  this.created_at,
 this.updated_at,
  );
  String id;
  String email;
  String topic;
  String subject;
  String pages;
  String style;
  String document;
  String academiclevel;
  String langstyle;
  String urgency;
  String spacing;
  String total;
  String description;
  String status;
  String payment;
  String created_at;
  String updated_at;


factory Myorder.fromJson(Map<String,dynamic>json)=>_$MyorderFromJson(json);
Map<String,dynamic> toJson()=>_$MyorderToJson(this);

}