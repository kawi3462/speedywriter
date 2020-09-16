import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'ordering/ordermodel.dart';

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
    _enablePlatformOverrideForDesktop();
    WidgetsFlutterBinding.ensureInitialized();
  runApp(
    
    MyApp(

      
model: OrderModel(),

  ));
}

