import 'package:json_annotation/json_annotation.dart';


part 'order.g.dart';

@JsonSerializable()

class Order
{
Order(

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


  
  );
   

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




factory Order.fromJson(Map<String,dynamic> json)=>_$OrderFromJson(json);

Map<String ,dynamic> toJson()=>_$OrderToJson(this);



}

