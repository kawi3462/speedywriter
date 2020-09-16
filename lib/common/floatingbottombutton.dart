import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class FloatingButton extends StatefulWidget {
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  bool _isUserLoggedIn = false;

  Widget build(BuildContext context) {
    _isUserLoggedIn = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .isUserLoggedIn;

    return FloatingActionButton(
        foregroundColor: speedyBrown900,
        backgroundColor: speedyPurple100,
        child: Icon(Icons.add),
        onPressed: () {
          _isUserLoggedIn ?
          Navigator.pushNamed(context, RouteNames.ordernow):  _showUserStatusDialog();
        });
  }


  _showUserStatusDialog() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: ' Would you like to login or sign up?',
      desc:
          'Before you can submit a new order you need to either login to your account or sign up ',
      btnCancelOnPress: () {
    
      },
      btnOkOnPress: () {
          Navigator.pushNamed(context, RouteNames.login);
      },
    )..show();
  }


}
