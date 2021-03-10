import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedywriter/account/resetdetails.dart';
import 'package:speedywriter/account/usermodel.dart';

import 'dart:convert';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/common/colors.dart';

import 'package:speedywriter/network_utils/api.dart';

class ResetPassword extends StatefulWidget {

  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formState = new GlobalKey();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String title = "Lastminutessay";
  String _userid;
  
  String _email;
  bool _isLoading = false;
  bool _isResendCodeLoading = false;
  bool _isEmailValid = false;
  int _pin;
  bool _isCorrect = false;
  bool _isWrong = false;
  bool _isEnabled = false;
  int _resendpin;

  _showMsg(String msg,Color color) {
    final snackbar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

//Check pin validity
  _checkpinValidity() {
    int pin = int.parse(_pinController.text);

    if (pin == _pin) {
      setState(() {
        _isEnabled = true;
        _isCorrect = true;
        _isWrong = false;
      });
    } else {
      setState(() {
        _isEnabled = false;
        _isWrong = true;
        _isCorrect = false;
      });
    }
  }

  void initState() {
    super.initState();
    _pinController.addListener(_checkpinValidity);
  }

  void dispose() {
    _pinController.dispose();

    super.dispose();
  }

//Resend code again

  void resendCode() async {
    _pinController.clear();
    setState(() {
      _isWrong = false;
      _isCorrect = false;
      _isEnabled = false;
    });
    int max = 9000;
    int min = 1000;
    Random rnd = new Random();
    _resendpin = min + rnd.nextInt(max - min);

    Map data = {'email': _email, 'pin': _pin};
    var apiUrl = "/user/sendpin";
 



    try {
      String jsonData = jsonEncode(data);

      var response = await Network().resetPassword(jsonData, apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          _isResendCodeLoading = false;
        });
       var jsonResponse = json.decode(response.body);
        _showMsg("Verification code has been sent to your email",Colors.green);
      } else if (response.statusCode == 404) {
        setState(() {
          _isResendCodeLoading = false;
        });

        _showMsg("Email not registered",Colors.blue);
      } else if (response.statusCode == 500) {
        setState(() {
          _isResendCodeLoading = false;
        });

        _showMsg("Server connection error:500",Colors.red);
      } else {
        setState(() {
          _isResendCodeLoading = false;
        });
        _showMsg("Error code..Check internet connection or info your submitting",Colors.red);
      }
    } catch (e) {
      setState(() {
        _isResendCodeLoading = false;
      });
      _showMsg("Cannot connect with the  server",Colors.red);
    }
  }

//end resend code method

//Method to check if the user is registered
  void checkPassword() async {
    setState(() {
      _isEnabled = false;
    });

    Map data = {
      'password': _passwordController.text,
      'pin': _pin,
    };
    var apiUrl = "/user/validatepin/"+_userid;



    try {
      String jsonData = jsonEncode(data);

      var response = await Network().resetPassword(jsonData, apiUrl);

      if (response.statusCode == 200 ){

       
    //  var   jsonResponse = json.decode(response.body);
    //     if (jsonResponse != null) {

          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          Map data = {'email': _email, 'password': _passwordController.text};
     

   

          String jsonData = jsonEncode(data);

          var res = await Network().loginData(jsonData);

          if (res.statusCode == 200) {
          var  jsResponse = json.decode(res.body)['data'];
            if (jsResponse != null) {
              sharedPreferences.setString("token", jsResponse['api_token']);
              sharedPreferences.setString('email', _email);
               sharedPreferences.setString('userid', jsResponse['id'].toString());
              

          

            var apiUrl ="/user/"+jsResponse['id'].toString();
          

            var userdetailsresponse = await Network()
                .getUserData(apiUrl, jsResponse['api_token']);

            Map userMap = jsonDecode(userdetailsresponse.body)['data'];
            ScopedModel.of<UserModel>(context, rebuildOnChange: true)
                .addUserDetails(userMap);
            ScopedModel.of<UserModel>(context, rebuildOnChange: true)
                .setUserStatus(true);
           ScopedModel.of<UserModel>(context, rebuildOnChange: true)
         .setTokenAndUserEmail(jsResponse['api_token'], _email,jsResponse['id'].toString());
    setState(() {
                _isLoading = false;
              });
            }
            _showMsg("Password reset successfully",Colors.green);

          }

          Navigator.pushNamed(context,RouteNames.home);
        // }
      } 
      else if (response.statusCode == 404) {
        setState(() {
          _isEnabled = true;
          _isLoading = false;
        });
        _showMsg("Pin code not found",Colors.blue);
      } else if (response.statusCode == 500) {
        setState(() {
          _isEnabled = true;
          _isLoading = false;
        });

        _showMsg("Server connection error",Colors.red);
      } else {
        _showMsg("Error..Check internet connection or info your submitting",Colors.red);
        setState(() {
          _isLoading = false;
          _isEnabled = true;
        });
      }
    } catch (e) {
  
      setState(() {
        _isLoading = false;
        _isEnabled = true;
      });
      _showMsg("Cannot connect with the  server",Colors.red);
    }
  }

//End check email method

  @override
  Widget build(BuildContext context) {
    final ResetDetails _resetDetails =
        ModalRoute.of(context).settings.arguments;
    if (_isResendCodeLoading) {
      setState(() {
        _pin = _resendpin;
      });
    } else {
      _pin = _resetDetails.pin;
    }

    _userid = _resetDetails.userid;
    _email=_resetDetails.email;

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
                        SizedBox(height: 30.0),
                        Text('Enter Verification Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            )),
                        SizedBox(height: 10.0),
                        Text('Code has been sent to your registered email'),
                        SizedBox(height: 15.0),
                        AccentColorOverride(
                            color: speedyBrown900,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _pinController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your Verification code";
                                } else
                                  return null;
                              },
                              onSaved: (String value) {
                                _pin =value.length>1? int.parse(value):null;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: new Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15, left: 5, right: 0, bottom: 15),
                                    child: new SizedBox(
                                        height: 4,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            _isWrong
                                                ? Icon(Icons.cancel,
                                                    color: Colors.red)
                                                : SizedBox(
                                                    width: 1,
                                                  ),
                                            _isCorrect
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )
                                                : SizedBox(
                                                    width: 1,
                                                  )
                                          ],
                                        )),
                                  ),
                                  filled: true,
                                  labelText: 'Verification code '),
                            )),
                        SizedBox(height: 2.0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("Didn't get the code?"),
                              _isResendCodeLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(width: 5),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      _isResendCodeLoading = true;
                                    });
                                    resendCode();
                                  },
                                  child: Text(
                                    'Resend code',
                                    style: TextStyle(color: speedyPurple300),
                                  ))
                            ]),
                        SizedBox(height: 16.0),
                        Text('Update Your Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            )),
                        SizedBox(height: 16.0),
                        AccentColorOverride(
                            color: speedyBrown900,
                            child: TextFormField(
                                enabled: _isEnabled,
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
                                enabled: _isEnabled,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please  confirm  your new password";
                                  } else
                                    return null;
                                },
                                obscureText: true,
                                controller: _confirmpasswordController,
                                decoration: InputDecoration(
                                    filled: true,
                                    labelText: 'Confirm Password'))),
                        SizedBox(height: 20.0),
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
                                  onPressed: _isEnabled
                                      ? () {
                                          if (_formState.currentState
                                              .validate()) {
                                            if (_passwordController.text ==
                                                _confirmpasswordController
                                                    .text) {
                                            checkPassword();

                                              setState(() {
                                                _isLoading = true;
                                              });
                                            } else {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              _showMsg(
                                                  "Password and Confirm password dont match !.",Colors.redAccent);
                                            }
                                          }
                                        }
                                      : null,
                                )),
                            SizedBox(height: 14.0),
                            FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, RouteNames.login);
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
