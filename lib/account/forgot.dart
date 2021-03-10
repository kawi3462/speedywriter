import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:speedywriter/account/resetdetails.dart';
import 'package:speedywriter/account/resetpassword.dart';

import 'package:speedywriter/common/colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:speedywriter/common/routenames.dart';

class Forgot extends StatefulWidget {
  static const routeName = RouteNames.forgot;

  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formState = new GlobalKey();
  final TextEditingController _emailController = TextEditingController();

  final String title = "Lastminutessay";
  String _email;
  bool _isLoading = false;
  bool _isEmailValid = false;
  int _pin;

  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

//Method to check if the user is registered
  void checkEmail(String email) async {
    int max = 9000;
    int min = 1000;
    Random rnd = new Random();
    _pin = min + rnd.nextInt(max - min);

    Map data = {'email': email, 'pin': _pin};
    var apiUrl = "/user/sendpin";

 

    try {
      String jsonData = jsonEncode(data);

      var response = await Network().resetPassword(jsonData, apiUrl);

      if (response.statusCode == 200) {
      var   jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          setState(() {
            _isLoading = false;
          });
        }

  

        Navigator.pushNamed(context, RouteNames.resetpassword,
            arguments: ResetDetails( jsonResponse['id'].toString(),email, _pin));
      } else if (response.statusCode == 404) {
        setState(() {
          _isLoading = false;
        });
        _showMsg("Email not registered");
      } else if (response.statusCode == 500) {
        setState(() {
          _isLoading = false;
        });

        _showMsg("Server connection error");
      } else {
        _showMsg("Error..Check internet connection or info your submitting");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      _showMsg("Cannot connect with the  server");
    }
  }

//End check email method

  void initState() {
    super.initState();
  }

  void dispose() {
    _emailController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: SafeArea(
          child: Form(
              key: _formState,
              child: ListView(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFE3D3E7),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    child: Column(children: [
                      SizedBox(height: 30.0),
                      Column(
                        children: <Widget>[
                          Image.asset('assets/icon/logo.png'),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(title.toUpperCase()),
                          SizedBox(height: 40.0)
                        ],
                      )
                    ]),
                  ),
                  Container(
                    color: speedyBackgroundWhite,
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        Text(
                          'Forgot your Password ?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text('Enter your email address and click submit'),
                        SizedBox(height: 15.0),
                        AccentColorOverride(
                            color: speedyBrown900,
                            child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter your email";
                                  } else
                                    return null;
                                },
                                onSaved: (String value) {
                                  _email = value;
                                },
                                decoration: InputDecoration(
                                    filled: true, labelText: 'Email '))),
                        SizedBox(height: 16.0),
                        SizedBox(height: 40.0),
                        Column(
                          children: <Widget>[
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
                                      _formState.currentState.validate();

                                      _isEmailValid = EmailValidator.validate(
                                          _emailController.text);

                                      if (_isEmailValid) {
                                        checkEmail(_emailController.text);
                                        setState(() {
                                          _isLoading = true;
                                        });
                                      } else {
                                        _showMsg("Enter a valid email");

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    })),
                            SizedBox(height: 14.0),
                            FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, RouteNames.login);
                                },
                                child: Text('Have Account ? Login')),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ))),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  AccentColorOverride({Key key, @required this.color, @required this.child})
      : super(key: key);
  Widget child;
  Color color;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
      child: child,
    );
  }
}
