
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class CustomClipPath extends CustomClipper<Path> {
 
  @override
  Path getClip(Size size) {
    var radius=10.0;
     Path path = Path();
    path.moveTo(radius, 0.0);
    path.arcToPoint(Offset(0.0, radius),
        clockwise: true, radius: Radius.circular(radius));
    path.lineTo(0.0, size.height - radius);
    path.arcToPoint(Offset(radius, size.height),
        clockwise: true, radius: Radius.circular(radius));
    path.lineTo(size.width - radius, size.height);
    path.arcToPoint(Offset(size.width, size.height - radius),
        clockwise: true, radius: Radius.circular(radius));
    path.lineTo(size.width, radius);
    path.arcToPoint(Offset(size.width - radius, 0.0),
        clockwise: true, radius: Radius.circular(radius));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }



}


class CustomClipPathHomeIMage extends CustomClipper<Path>{
@override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width/4, size.height
 - 40, size.width/2, size.height-20);
    path.quadraticBezierTo(3/4*size.width, size.height,
 size.width, size.height-30);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }



}
//Phone update
class  CustomWave  extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    Path path = Path();
path.lineTo(0, size.height);
path.quadraticBezierTo(size.width/4, size.height - 50, size.width/2, size.height-20);
path.quadraticBezierTo(3/4*size.width, size.height, size.width, size.height-40);
path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }




}



  