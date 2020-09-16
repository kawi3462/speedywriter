import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/forgot.dart';
import 'package:speedywriter/account/manageorders/myorders.dart';
import 'package:speedywriter/account/profile.dart';
import 'package:speedywriter/account/register.dart';
import 'package:speedywriter/account/resetpassword.dart';
import 'package:speedywriter/account/updatepassword.dart';
import 'package:speedywriter/account/usermodel.dart';
import 'package:speedywriter/approuteobserver.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/firstpage.dart';
import 'package:speedywriter/home.dart';

import 'package:speedywriter/ordering/getquote.dart';
import 'package:speedywriter/ordering/paypal.dart';
import 'package:speedywriter/ordering/uploadmaterials.dart';
import 'common/colors.dart';

import 'account/login.dart';
import 'common/cutcornerborders.dart';

import 'ordering/orderthankyou.dart';
import 'ordering/ordermodel.dart';
import 'ordering/orderstrings.dart';
import 'ordering/ordercalculations.dart';
import 'ordering/orderingstagetwo.dart';
import 'account/manageorders/editorder.dart';

class MyApp extends StatefulWidget {
  final OrderModel model = OrderModel();

  MyApp({Key key, @required model}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return ScopedModel(

        //End todo :implement

        model: UserModel(),
        child: ScopedModel(
            model: widget.model,
            child: MaterialApp(
              theme: _speedyTheme,
              initialRoute: '/',
              navigatorObservers: [AppRouteObserver()],
              routes: {
                RouteNames.home: (_) => FirstPage(),
                RouteNames.login: (_) => Login(),
                RouteNames.register: (_) => Register(),
                RouteNames.forgot: (_) => Forgot(),
                RouteNames.getquote: (_) => GetQuote(
                    orderStrings: OrderStrings(),
                    model: widget.model,
                    orderCalculations: OrderCalculations()),
                RouteNames.ordernow: (_) => MyHomePage(
                      model: widget.model,
                      orderCalculations: OrderCalculations(),
                      orderStrings: OrderStrings(),
                    ),
                RouteNames.profile: (_) => Profile(),
      RouteNames.resetpassword: (context) => ResetPassword(),
           RouteNames.orderStageTwo :(context) => OrderStageTwo(
                      model: widget.model,
                    ),
                RouteNames.orderthankyou: (_) =>
                    OrderThankYou(model: widget.model),
                RouteNames.uploadMaterial: (_) => UploadMaterial(),
                RouteNames.paypal: (_) => PayPal(model: widget.model),
                RouteNames.updatePassword: (_) => UpdatePassword(),
                RouteNames.myorders: (_) => MyOrders(),
                RouteNames.editorder: (_) => EditOrder(),
              },
            )));
  }
}

//Add Application routes

//Build Speedy theme
final ThemeData _speedyTheme = _buildSpeedyTheme();

ThemeData _buildSpeedyTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
      accentColor: speedyBrown900,
      primaryColor: speedyPurple100,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: speedyPurple100,
        colorScheme: base.colorScheme.copyWith(secondary: speedyBrown900),
      ),
      buttonBarTheme:
          base.buttonBarTheme.copyWith(buttonTextTheme: ButtonTextTheme.accent),
      iconTheme: base.iconTheme.copyWith(color: speedyBrown900),
      scaffoldBackgroundColor: speedyBackgroundWhite,
      cardColor: speedyBackgroundWhite,
      textSelectionColor: speedyPurple100,
      errorColor: speedyErrorRed,
      primaryTextTheme: _buildSpeedyTextTheme(base.primaryTextTheme),
      primaryIconTheme: base.iconTheme.copyWith(color: speedyBrown900),
      inputDecorationTheme: InputDecorationTheme(border: CutCornersBorder()));
}

ListTileTheme _listTileTheme(ListTileTheme base) {
  new ListTileTheme(
    selectedColor: speedyPurple400,
  );
}

// TODO: Add the text themes (103)

TextTheme _buildSpeedyTextTheme(TextTheme base) {
  return base
      .copyWith(
          headline: base.headline.copyWith(
            fontWeight: FontWeight.w500,
          ),
          title: base.title.copyWith(fontSize: 18.0),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          display1: base.display1.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 18.0,
              fontWeight: FontWeight.w400),
          display4: base.display4.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 10.0,
              fontWeight: FontWeight.w100))
      .apply(
        fontFamily: 'Rubik',
        displayColor: speedyBrown900,
        bodyColor: speedyBrown900,
      );
}

// TODO: Add the icon themes (103)
// TODO: Decorate the inputs (103)
