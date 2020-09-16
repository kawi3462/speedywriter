import 'dart:convert';
import 'package:http/http.dart' as http;

import "package:flutter/material.dart";
import 'package:scoped_model/scoped_model.dart';

import 'package:speedywriter/account/usermodel.dart';


import 'package:speedywriter/common/clippathcutcorners.dart';
import 'package:speedywriter/common/colors.dart';


import 'package:speedywriter/network_utils/api.dart';

import 'package:speedywriter/serializablemodelclasses/user.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speedywriter/common/page_titles.dart';

import 'dart:io';
import 'package:speedywriter/common/routenames.dart';

import 'package:speedywriter/appscaffold_two.dart';

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<FormState> _formkey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
  TextEditingController _phoneController = TextEditingController();
  //Updating profile image variables
  File _imageFile;
  // To track the file uploading state
  bool _isUploading = false;

  //end profile image variables
  String _baseUrl = Network().url + "/adduseravatar";
  String _token;

  User _user;
  //Start adding bottom nav==========
  String _lastSelected = 'TAB: 0';
  bool _isPhoneempty = false;
  bool _isLoading = false;

  String _phone;
  bool _isUserLoggedIn = false;

  bool _hasprofileimage = false;
  String _imageUrl;

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      if (index == 0) {
        Navigator.pushNamed(context, RouteNames.getquote);
      }
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

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
//==========End adding bottombar==========

//Dialog to select image source
  Future<void> _showDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            title: Text('Pick an Image'),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                Text('Select your image source '),
              ],
            )),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton.icon(
                      onPressed: () {
                        _getImage(context, ImageSource.camera);
                      },
                      icon: Icon(Icons.photo_camera),
                      label: Text('Camera')),
                  SizedBox(width: 20),
                  RaisedButton.icon(
                      onPressed: () {
                        _getImage(context, ImageSource.gallery);

                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.collections),
                      label: Text('Gallery'))
                ],
              )
            ],
          );
        });
  }

//End image source dialog
//Upload image
  void _uploadImage(File image) async {
    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;

    setState(() {
      _isUploading = true;
      ScopedModel.of<UserModel>(context, rebuildOnChange: true)
          .setUserProfileImageStatus(false);
    });
    var postUri = Uri.parse(_baseUrl);
    var request = http.MultipartRequest("POST", postUri);
    request.headers['authorization'] = "Bearer $_token";
    request.headers['Content-Type'] = "multipart/form-data";
    request.fields['id'] = _user.id.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        image.path,
      ),
    );

    var jsonResponse;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        jsonResponse = json.decode(response.body);

        setState(() {
          _isUploading = false;
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .setUserProfileImageStatus(true);
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .updateUserProfileImage(jsonResponse['path']);

          _imageUrl = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .avatarImageUrl;
         
        });
        _showMsg("Profile image added successfully");
      } else {
        _showMsg(
            "Application encountered error..Unable to upload your profile image");
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print(e);
      _showMsg(
          "Application encountered error..Unable to upload your profile image");
      setState(() {
        _isUploading = false;
      });
    }
  }

//end uploading image method
//Method to get image from camera or gallery

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = image;
    });

    _uploadImage(_imageFile);

Navigator.pop(context);
  }
//End get image method

  @override
  Widget build(BuildContext context) {
    _user = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user;
    _isUserLoggedIn = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .isUserLoggedIn;

    if (_isUserLoggedIn) {
      _user = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user;

      _hasprofileimage =
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .userHasProfileImage;

      setState(() {
        _imageUrl = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .avatarImageUrl;
      });
    }

    return AppScaffoldTwo(
 
        key: _scaffoldState,
    pageTitle: PageTitles.myprofile,
        body: SafeArea(
          child: ListView(children: [
            Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 40),
                child: Card(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          _showDialog();
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 2.0,
                                color: speedyPurple100,
                              ),
                              shape: BoxShape.circle),
                          child: CircleAvatar(
                              backgroundColor: Color(0xFFE6F0FA),
                              radius: 75,
                              child: ClipOval(
                                child: _hasprofileimage
                                    ? Image.network(
                                        _imageUrl,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : _isUploading
                                        ? CircularProgressIndicator()
                                        : CircleAvatar(
                            radius: 74,
                            child: Image.asset('assets/icons/account.png'),
                          ),
                              )),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _user.name,
                        style: TextStyle(color: speedyBrown900),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _user.email,
                        style: TextStyle(color: speedyBrown900),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "User ID : " + _user.id.toString(),
                        style: TextStyle(color: speedyBrown900),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Referral Points : " + _user.referral_points,
                        style: TextStyle(color: speedyBrown900),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.location_on),
                          Text(
                            _user.country,
                            style: TextStyle(color: speedyBrown900),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.phone),
                          Text(
                            _user.phone,
                            style: TextStyle(color: speedyBrown900),
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Sign Up Date : " + _user.created_at,
                        style: TextStyle(color: speedyBrown900),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Last Profile Update : " + _user.updated_at,
                        style: TextStyle(color: speedyBrown900),
                      ),
                      SizedBox(height: 10),
                      Material(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.grey[100],
                        child: FlatButton(
                          child: Text('Update Phone Number'),
                          onPressed: () {
                            //_updatePhoneBottomSheet(context);

                            showModalBottomSheet(
                                isDismissible: true,
                                useRootNavigator: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                context: context,
                                builder: (BuildContext context) {
                                  return UpdatePhoneBottomSheet();
                                });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Material(
                          color: Theme.of(context).primaryColor,
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                            width: 200,
                            child: MaterialButton(
                              child: Text('Update Password'),
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.updatePassword);
                              },
                            ),
                          )),
                      SizedBox(height: 20),
                    ])),
              ),
            )
          ]),
        ),
  
        
        
        );
  }
}

class UpdatePhoneBottomSheet extends StatefulWidget {
  _UpdatePhoneBottomSheet createState() => _UpdatePhoneBottomSheet();
}

class _UpdatePhoneBottomSheet extends State<UpdatePhoneBottomSheet> {
  final GlobalKey<ScaffoldState> _updateScaffold = new GlobalKey();

  bool _isPhoneempty = false;
  bool _isLoading = false;
  bool _isEnabled = true;
  Country _selected;
  Country _displayCountry = Country.US;
  String _phone;
  String _dialcode = "1";
  String _countryname = "United States";
  TextEditingController _phoneController = TextEditingController();
  User _user;

  _showMsg(String msg) {
    final snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _updateScaffold.currentState.showSnackBar(snackbar);
  }

  void _updatePhone(String _phone, String _countryname) async {
    String _email = _user.email;
    String _token =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;

    Map _data = {'email': _email, 'phone': _phone, 'country': _countryname};
    var apiUrl = "/updatephone";

    try {
      String _jsonData = jsonEncode(_data);

      var _response = await Network().submitData(_jsonData, apiUrl, _token);

      if (_response.statusCode == 201) {
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .updatePhoneLoggedUser(_phone, _countryname);

        setState(() {
          _isLoading = false;
        });
        _showMsg("Phone update successful");

        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.pop(context);
        });
      } else if (_response.statusCode == 400) {
        setState(() {
          _isLoading = false;
          _isEnabled = true;
        });
        _showMsg("Phone  update failed..Kindly try again");
      } else if (_response == null) {
        setState(() {
          _isLoading = false;
          _isEnabled = true;
        });
        _showMsg("Unable to connect with remote server");
      } else {
        setState(() {
          _isLoading = false;
          _isEnabled = true;
        });
        _showMsg("System encoutered an error.Kindly try again");
      }
    } catch (e) {
      _showMsg("System encoutered an error.Kindly try again");
      setState(() {
        _isLoading = false;
        _isEnabled = true;
      });
    }
  }

  Widget build(BuildContext context) {
    _user = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user;
    return Scaffold(
        backgroundColor: speedySurfacebackground,
        key: _updateScaffold,
        body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: ListView(
            padding: EdgeInsets.only(left: 20, right: 20),
            children: [
              SizedBox(height: 15),
              Center(
                child: Text(
                  'Update Phone Number',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: speedyBrown900),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Select Country",
                style: TextStyle(
                  color: speedyBrown900,
                ),
              ),
              SizedBox(height: 5),
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
                          showFlag: true, //displays flag, true by default
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
              SizedBox(height: 10),
              _isPhoneempty
                  ? Text(
                      "Please enter your phone number",
                      style: TextStyle(color: speedyErrorRed),
                    )
                  : SizedBox(),
              AccentColorOverride(
                  color: speedyBrown900,
                  child: TextFormField(
                      controller: _phoneController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter your phone number";
                        } else
                          return null;
                      },
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      //  controller: _emailController,
                      decoration:
                          InputDecoration(filled: true, labelText: 'Phone '))),
              SizedBox(height: 15),
              Material(
                  color: Theme.of(context).primaryColor,
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  child: Container(
                      width: 200,
                      child: MaterialButton(
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
                                if (_phoneController.text
                                    .toString()
                                    .isNotEmpty) {
                                  setState(() {
                                    _isLoading = true;
                                    _isEnabled = false;
                                    _isPhoneempty = false;
                                  });

                                  String _phonenumber = '+' +
                                      _dialcode +
                                      _phoneController.text.toString();
                                  _updatePhone(_phonenumber, _countryname);
                                } else {
                                  setState(() {
                                    _isPhoneempty = true;
                                  });
                                }
                              }
                            : null,
                      ))),
            ],
          ),
        ));
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride(
      {Key key, @required this.child, @required this.color})
      : super(key: key);
  final Widget child;
  final Color color;

  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context)
          .copyWith(accentColor: color, brightness: Brightness.dark),
    );
  }
}
