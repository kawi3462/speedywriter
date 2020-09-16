import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';



import 'package:flutter/foundation.dart';

import 'app.dart';
import 'ordering/ordermodel.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
runApp(
    
    MyApp(

      
model: OrderModel(),

  ));
}