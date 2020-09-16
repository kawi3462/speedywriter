import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';
import 'package:speedywriter/common/appbar.dart';

import 'package:speedywriter/common/colors.dart';

import 'package:speedywriter/network_utils/api.dart';

import 'package:speedywriter/appscaffold_two.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/common/routenames.dart';

class UpdatePassword extends StatefulWidget {
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
  final GlobalKey<FormState> _formState = new GlobalKey();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool keyboardOpen = false;
  bool _isLoading = false;

  //Start adding bottom nav==========

  @override
  void initState() {
    super.initState();
  }

//Check if keyboard open so that order now icon cannot show
  _checkIfKeyBoardOpen() {
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      setState(() {
        keyboardOpen = true;
      });
    } else {
      setState(() {
        keyboardOpen = false;
      });
    }
  }

//End check keyboard
//Scaffold snackbar
  _showMsg(String msg) {
    final snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldState.currentState.showSnackBar(snackbar);
  }

  //End scaffold snack bar
  void updatePassword(String _password) async {
    String _token =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
    String _email =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).user.email;

    Map _data = {'email': _email, 'password': _password};
    var apiUrl = "/loggedResetPassword";

    try {
      String _jsonData = jsonEncode(_data);

      var _response = await Network().submitData(_jsonData, apiUrl, _token);
      if (_response.statusCode == 201) {
        _showMsg("Password update successful..Kindly login again");

        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .setUserStatus(false);
        await Network().logOut();
        Navigator.pushNamed(context, RouteNames.login);
      } else if (_response.statusCode == 400) {
        _showMsg("Password update failed..Kindly try again");
      } else if (_response == null) {
        _showMsg("Unable to connect with remote server");
      } else {
        _showMsg("System encoutered an error.Kindly try again");
      }
    } catch (e) {
      print("error==========================");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkIfKeyBoardOpen();
    return Scaffold(
      key: _scaffoldState,
      appBar: buildAppBar(PageTitles.updatepassword),
   // pageTitle: PageTitles.updatepassword,
      body: SafeArea(
          child: Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 40),
              child: Center(
                  child: Form(
                      key: _formState,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 16.0),
                          AccentColorOverride(
                              color: speedyBrown900,
                              child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please enter your new password";
                                    } else
                                      return null;
                                  },
                                  obscureText: true,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                      filled: true, labelText: 'Password'))),
                          SizedBox(height: 16.0),
                          AccentColorOverride(
                              color: speedyBrown900,
                              child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please  confirm  your new password";
                                    } else
                                      return null;
                                  },
                                  obscureText: true,
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                      filled: true,
                                      labelText: 'Confirm Password'))),
                          SizedBox(height: 20.0),
                          Material(
                              color: Theme.of(context).primaryColor,
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(30.0),
                              child: MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  child: _isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            CircularProgressIndicator(),
                                            Text('Submit')
                                          ],
                                        )
                                      : Text('Submit'),
                                  elevation: 12.0,
                                  onPressed: () {
                                    if (_formState.currentState.validate()) {
                                      if (_passwordController.text ==
                                          _confirmPasswordController.text) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        updatePassword(
                                            _passwordController.text);
                                      } else {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _showMsg(
                                            "Password and Confirm password dont match !.");
                                      }
                                    }
                                  })),
                        ],
                      ))))),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride(
      {Key key, @required this.color, @required this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context)
            .copyWith(accentColor: color, brightness: Brightness.dark),
        child: child);
  }
}
