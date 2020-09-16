import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData _speedyTheme=_buildSpeedyTheme();

ThemeData _buildSpeedyTheme(){
  final ThemeData base=ThemeData.light();
  return base.copyWith(
accentColor: speedyBrown900,
    primaryColor: speedyPurple100,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: speedyPurple100,
      colorScheme: base.colorScheme.copyWith(
        secondary: speedyBrown900
      ),

    ),
    iconTheme: base.iconTheme.copyWith(
color:base.accentColor,


    ),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent

    ),
    scaffoldBackgroundColor: speedyBackgroundWhite,
    cardColor: speedyBackgroundWhite,
    textSelectionColor: speedyPurple100,
    errorColor: speedyErrorRed,


  );
  


}