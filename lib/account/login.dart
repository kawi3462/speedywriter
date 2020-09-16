import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedywriter/account/forgot.dart';
import 'package:speedywriter/account/usermodel.dart';

import 'package:speedywriter/common/colors.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:email_validator/email_validator.dart';
import 'package:html/parser.dart';

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKeyLogin = new GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String title = "Lastminutessay";
  SharedPreferences sharedPreferences;
  FocusNode _focusNodeEmail;
  FocusNode _focusNodePassword;
  FocusNode _focusNodeLoginButton;

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool get validateFields {
    if (_emailController.text != "" || _passwordController.text != "") {
      return true;
    } else
      return false;
  }

//Moving to next focusn

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

//End next focus
//Start validating user login details
  void _validateUserLoginDetails() {
    if (_formKeyLogin.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      _isEmailValid = EmailValidator.validate(_emailController.text);
      if (_isEmailValid) {
        signIn(_emailController.text, _passwordController.text);
      } else {
        _showMsg("Enter a valid email");

        setState(() {
          _isLoading = false;
        });
      }
    }
  }
//End user details validation

  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

  void signIn(String email, String pass) async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      print(e);
    }

    Map data = {'email': email, 'password': pass};
    var apiUrl = "/login";

    var jsonResponse = null;

    try {
      String jsonData = jsonEncode(data);

      var response = await Network().loginData(jsonData, apiUrl);

      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          sharedPreferences.setString("token", jsonResponse['access_token']);
          sharedPreferences.setString('email', email);
          var apiUrl = "/user";

          var userdetailsresponse =
              await Network().getUserData(apiUrl, jsonResponse['access_token']);

          Map userMap = jsonDecode(userdetailsresponse.body);
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .addUserDetails(userMap);
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .setUserStatus(true);
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .setTokenAndUserEmail(jsonResponse['access_token'], email);

          setState(() {
            _isLoading = false;
          });
        }

        Navigator.pushNamed(context, RouteNames.home);
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
        });
        _showMsg("Wrong email or password");
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
      _showMsg(
          "Cannot connect with the  server..Check your internet connection");
    }
  }

  void initState() {
    super.initState();
  }

  void dispose() {
    _emailController.clear();
    _passwordController.clear();

    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusNodeEmail = FocusNode();
    _focusNodePassword = FocusNode();

    return Scaffold(
        key: _scaffoldkey,
        body: SafeArea(
          child: Form(
              key: _formKeyLogin,
              child: ListView(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFE3D3E7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          // bottomRight: Radius.circular(30)
                        )),
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
                        SizedBox(height: 60.0),
                        AccentColorOverride(
                            color: speedyBrown900,
                            child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please  enter your Email";
                                  } else
                                    return null;
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: _focusNodeEmail,
                                onFieldSubmitted: (term) {
                                  _fieldFocusChange(context, _focusNodeEmail,
                                      _focusNodePassword);
                                },
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                decoration: InputDecoration(
                                    filled: true, labelText: 'Email '))),
                        SizedBox(height: 16.0),
                        AccentColorOverride(
                            color: speedyBrown900,
                            child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please  enter your password";
                                  } else
                                    return null;
                                },
                                textInputAction: TextInputAction.done,
                                focusNode: _focusNodePassword,
                                onFieldSubmitted: (value) {
                                  _focusNodePassword.unfocus();
                                  _validateUserLoginDetails();
                                },
                                obscureText: true,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                    filled: true, labelText: 'Password'))),
                        SizedBox(height: 8.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 5,
                                )),
                            Expanded(
                                flex: 1,
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, RouteNames.forgot);
                                    },
                                    child: Text('Forgot password')))
                          ],
                        ),
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
                                              Text('Login')
                                            ],
                                          )
                                        : Text('Login'),
                                    elevation: 12.0,
                                    onPressed: () {
                                      _validateUserLoginDetails();
                                    })),
                            SizedBox(height: 14.0),
                            FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, RouteNames.register);
                                },
                                child: Text('No Account? Sign Up')),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
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
        data: Theme.of(context).copyWith(
          accentColor: color,
          brightness: Brightness.dark,
        ),
        child: child);
  }
}
