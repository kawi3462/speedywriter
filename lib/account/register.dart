import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';
import 'package:speedywriter/common/clippathcutcorners.dart';
import 'package:speedywriter/common/colors.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:email_validator/email_validator.dart';
import 'package:speedywriter/common/page_titles.dart';

import 'package:flutter_country_picker/flutter_country_picker.dart';

class Register extends StatefulWidget {
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKeyRegister = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode _focusNodeFname;
  FocusNode _focusPhone;
  FocusNode _focusNodeEmail;
  FocusNode _focusNodePassword;
  FocusNode _focusNodeConfirmPassword;

  final String title = PageTitles.home;

  final GlobalKey<ScaffoldState> _scaffoldRegisterKey =
      GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;

  Country _displayCountry = Country.US;
  String _phone;
  Country _selected;
  String _dialcode = "1";
  String _countryname = "United States";

  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldRegisterKey.currentState.showSnackBar(snackbar);
  }

//Moving to next focusn

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

//End next focus

  bool get validateFields {
    if (_nameController.text != "" &&
        _emailController.text != "" &&
        _passwordController.text != "" &&
        _confirmpasswordController.text != "" &&
        _passwordController.text != "" &&
        _confirmpasswordController.text != "") {
      return true;
    } else
      return false;
  }

//Start validating user

  void _validateUserRegister() {
    if (_formKeyRegister.currentState.validate()) {
      _isEmailValid = EmailValidator.validate(_emailController.text);

      if (_isEmailValid) {
        setState(() {
          _isLoading = true;
        });

        if (_passwordController.text != _confirmpasswordController.text) {
          setState(() {
            _isLoading = false;
            _showMsg("Password and Confirm password dont match");
          });
        } else {
          _phone = "+" + _dialcode + _phoneController.text.toString();

          _registerUser(
              _nameController.text,
              _phone,
              _countryname,
              _emailController.text,
              _passwordController.text,
              _confirmpasswordController.text);
        }
      } else {
        _showMsg('Enter a valid email');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

//End validating user register

  void _registerUser(String name, String phone, String country, String email,
      String password, String passwordConfirm) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'name': name,
      'phone': phone,
      'country': country,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirm
    };

    String signupdata = jsonEncode(data);
    var apiUrl = "/signup";

    try {
      var response = await Network().authData(signupdata, apiUrl);

      if (response.statusCode == 201) {
        //Get User Information and register token and email
        Map logindata = {
          'email': email,
          'password': password,
        };
        apiUrl = "/login";
        var jsonResponse = null;
        String jsonData = jsonEncode(logindata);

        var response = await Network().signUpData(jsonData, apiUrl);
        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          if (jsonResponse != null) {
            sharedPreferences.setString("token", jsonResponse['access_token']);
            sharedPreferences.setString('email', email);

            var apiUrl = "/user";

            var userdetailsresponse = await Network()
                .getUserData(apiUrl, jsonResponse['access_token']);

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
          _showMsg("Your account has been registered");

          Navigator.pushNamed(context, RouteNames.home);
        }

        //End register of token and email
      } else if (response.statusCode == 422) {
        _showMsg(
            "The email has already been registered...Login or click forgot password please");

        setState(() {
          _isLoading = false;
        });
      } else if (response.statusCode >= 500) {
        _showMsg("Server connection error");
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      _showMsg("Cannot connect with the  server..Unable to sign up");
    }
  }

  void initState() {
    setState(() {
      super.initState();
    });
  }

  void dispose() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmpasswordController.clear();
    _focusNodeFname.dispose();
    _focusPhone.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

 _focusNodeFname = FocusNode();
 _focusPhone = FocusNode();
 _focusNodeEmail = FocusNode();
 _focusNodePassword = FocusNode();
  _focusNodeConfirmPassword = FocusNode();


    return Scaffold(
      key: _scaffoldRegisterKey,
      body: SafeArea(
        child: Form(
            key: _formKeyRegister,
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
                      SizedBox(height: 30.0),
                      AccentColorOverride(
                          color: speedyBrown900,
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please  enter your name";
                                } else
                                  return null;
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: _focusNodeFname,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _focusNodeFname, _focusPhone);
                              },
                              keyboardType: TextInputType.text,
                              controller: _nameController,
                              decoration: InputDecoration(
                                  filled: true,
                                  labelText: 'First & Second Name '))),
                      SizedBox(height: 16.0),
                      ClipPath(
                        child: AccentColorOverride(
                            color: speedyBrown900,
                            child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                ),
                                height: 50,
                                child: CountryPicker(
                                  dense: false,
                                  showFlag:
                                      true, //displays flag, true by default
                                  showDialingCode:
                                      true, //displays dialing code, false by default
                                  showName:
                                      true, //displays country name, true by default
                                  showCurrency: false, //eg. 'British pound'
                                  showCurrencyISO: false, //eg. 'GBP'
                                  onChanged: (Country country) {
                                    setState(() {
                                      _selected = country;
                                      _dialcode = _selected.dialingCode;
                                      _countryname = _selected.name;
                                    });
                                  },
                                  selectedCountry: _selected,
                                ))),
                        clipper: CustomClipPath(),
                      ),
                      SizedBox(height: 16.0),
                      AccentColorOverride(
                          color: speedyBrown900,
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please  enter your phone number";
                                } else
                                  return null;
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: _focusPhone,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _focusPhone, _focusNodeEmail);
                              },
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              controller: _phoneController,
                              decoration: InputDecoration(
                                  filled: true, labelText: 'Phone'))),
                      SizedBox(height: 16.0),
                      AccentColorOverride(
                          color: speedyBrown900,
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please  enter your email";
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
                              textInputAction: TextInputAction.next,
                              focusNode: _focusNodePassword,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(context, _focusNodePassword,
                                    _focusNodeConfirmPassword);
                              },
                              obscureText: true,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                  filled: true, labelText: 'Password'))),
                      SizedBox(height: 16.0),
                      AccentColorOverride(
                          color: speedyBrown900,
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please  confirm your password";
                                } else
                                  return null;
                              },
                              textInputAction: TextInputAction.done,
                              focusNode: _focusNodeConfirmPassword,
                              onFieldSubmitted: (value) {
                                _focusNodeConfirmPassword.unfocus();
                                _validateUserRegister();
                              },
                              obscureText: true,
                              controller: _confirmpasswordController,
                              decoration: InputDecoration(
                                  filled: true,
                                  labelText: 'Confirm Password'))),
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
                                            Text('Register')
                                          ],
                                        )
                                      : Text('Register'),
                                  elevation: 12.0,
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          _validateUserRegister();
                                        })),
                          SizedBox(height: 14.0),
                          FlatButton(
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.login);
                              },
                              child: Text('Have Account? Login')),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  AccentColorOverride({Key key, @required this.color, @required this.child})
      : super(key: key);
  final Widget child;
  final Color color;
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
