import 'package:json_annotation/json_annotation.dart';


part 'ordermaterial.g.dart';

@JsonSerializable()

class Ordermaterial{
 
 Ordermaterial(
   this.id,
   this.order_id,
   this.filename,
   this.original_filename,
   this.email,
   this.created_at,
   this.updated_at,

 


 );
   int id;
String order_id;
   String filename;
   String original_filename;
   String email;
   String created_at;
   String updated_at;


factory Ordermaterial.fromJson(Map<String,dynamic> json)=>_$OrdermaterialFromJson(json);

Map<String ,dynamic> toJson()=>_$OrdermaterialToJson(this);




}

