import 'package:json_annotation/json_annotation.dart';


part 'image.g.dart';

@JsonSerializable()


class Image{
int id;
String original_filename;
String path;


Image(this.id,
this.original_filename,
this.path
);


factory Image.fromJson(Map<String,dynamic> json)=>_$ImageFromJson(json);

Map<String ,dynamic> toJson()=>_$ImageToJson(this);


}
