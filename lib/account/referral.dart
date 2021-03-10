import 'dart:async';
import 'dart:convert';

import 'dart:core';

import "package:flutter/material.dart";
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';

import 'package:speedywriter/common/colors.dart';
import 'package:speedywriter/common/cutcornerborders.dart';

import 'package:speedywriter/common/page_titles.dart';

import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/network_utils/api.dart';

import 'package:speedywriter/presentation/custom_icons.dart';
import 'package:speedywriter/common/floatingbottombutton.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/common/bottomnav.dart';
import 'package:speedywriter/serializablemodelclasses/referral.dart';
import 'package:speedywriter/serializablemodelclasses/earning.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:speedywriter/appscaffold_two.dart';
import 'package:flutter/services.dart';

class ReferralUI extends StatefulWidget {
  _ReferralUIState createState() => _ReferralUIState();
}

class _ReferralUIState extends State<ReferralUI> {
  final GlobalKey<ScaffoldState> _scaffoldReferralState = new GlobalKey();
  bool _isPhoneempty = false;
  bool _isLoading = false;
  bool _isEnabled = true;
  String _lastSelected = 'TAB: 0';
  int index;
  bool _isIndex = false;
  bool _isTablet = false;
  String _token;
  String _userid;
  List<Referral> _referralList;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    setState(() {
      if (_width > 1000) {
        _isTablet = true;
      }
    });
    ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .loadUserReferrals();

    _referralList =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).referralList;

    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;

    return AppScaffoldTwo(
        pageTitle: PageTitles.referral,
        body: SafeArea(
          child: ListView(children: [
            Image.asset(
              'assets/images/friends-2.jpg',
              // gaplessPlayback: true,
              width: MediaQuery.of(context).size.width,
              height: 200,
            ),
            Center(
                child: Text(
              'Invite Friends & Earn Amazing Rewards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            )),
            Container(
              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              )),
              child: RaisedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                        isDismissible: true,
                        useRootNavigator: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        context: context,
                        builder: (BuildContext context) {
                          return AddReferralBottomSheet();
                        });
                  },
                  label: Text(
                    'Add More',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(Icons.add, color: Colors.white),
                  color: Colors.green),
            ),
            _isTablet
                ? Card(
                    elevation: 5,
                    margin: EdgeInsets.fromLTRB(5, 10, 5, 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _referralList.length <= 0
                        ? Center(
                            child: Text(
                                'You dont have any referrals.Consider adding some and earn rewards',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                    color: Colors.redAccent)))
                        : referralTableTabletScreen(_referralList))
                : Card(
                    elevation: 5,
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _referralList.length <= 0
                        ? Center(
                            child: Text(
                                'You dont have any referrals.Consider adding some and earn rewards',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Colors.redAccent)))
                        : referralTableSmallScreen(_referralList)),
          ]),
        ));
  }

  SingleChildScrollView referralTableSmallScreen(List<Referral> _referral) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showBottomBorder: true,
        sortColumnIndex: 0,
        showCheckboxColumn: false,
        columns: [
          DataColumn(
            label: Text(
              'Ref #',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Email',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: _referral
            .map(
              (referral) => DataRow(cells: [
                DataCell(Text(referral.id.toString())),
                DataCell(Text(referral.email)),
                DataCell(Text(referral.status)),
              ]),
            )
            .toList(),
      ),
    );
  }

  SingleChildScrollView referralTableTabletScreen(List<Referral> _referral) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        sortColumnIndex: 1,
        showCheckboxColumn: false,
        columns: [
          DataColumn(
            label: Text(
              'Ref #',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Email',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Phone',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: _referral
            .map(
              (referral) => DataRow(cells: [
                DataCell(Text(referral.id.toString())),
                DataCell(Text(referral.name)),
                DataCell(Text(referral.email)),
                DataCell(Text(referral.phone)),
                DataCell(Text(referral.status)),
              ]),
            )
            .toList(),
      ),
    );
  }
}

class AddReferralBottomSheet extends StatefulWidget {
  _AddReferralBottomSheet createState() => _AddReferralBottomSheet();
}

class _AddReferralBottomSheet extends State<AddReferralBottomSheet> {
  final GlobalKey<FormState> _formKeyReferral = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final CutCornersBorder cutcornersborder = new CutCornersBorder();

  FocusNode _focusNodeFname;
  FocusNode _focusPhone;
  FocusNode _focusNodeEmail;

  final String title = PageTitles.home;

  final GlobalKey<ScaffoldState> _addReferralScaffold =
      GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;

  String _token;
  String _userid;

  Country _displayCountry = Country.US;
  String _phone;
  Country _selected;
  String _dialcode = "1";
  String _countryname = "United States";
  _showMsg(String msg, Color color) {
    final snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _addReferralScaffold.currentState.showSnackBar(snackbar);
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _validateReferralDetails() {
    if (_formKeyReferral.currentState.validate()) {
      _isEmailValid = EmailValidator.validate(_emailController.text);

      if (_isEmailValid) {
        setState(() {
          _isLoading = true;
        });

        _phone = "+" + _dialcode + _phoneController.text.toString();

        _addReferral(
          _nameController.text,
          _phone,
          _countryname,
          _emailController.text,
        );
      } else {
        _showMsg('Enter a valid email', Colors.redAccent);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addReferral(
      String name, String phone, String country, String email) async {
    Map data = {
      'name': name,
      'email': email,
      'country': country,
      'phone': phone
    };

    String _referralData = jsonEncode(data);
    var _apiUrl = "/user/" + _userid + "/referrals";

    try {
      // String _jsonData = jsonEncode(_data);

      var _response =
          await Network().submitData(_referralData, _apiUrl, _token);

      if (_response.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });
        _showMsg("Referral added successfully", Colors.green);

        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.pop(context);
        });
      } else if (_response.statusCode == 422) {
        setState(() {
          _isLoading = false;
          // _isEnabled = true;
        });
        _showMsg("User has been added already", Colors.red);
      }
      //  else if (_response == null) {
      //   setState(() {
      //     _isLoading = false;
      //     // _isEnabled = true;
      //   });

      //   _showMsg("Unable to connect with remote server", Colors.red);
      // }
      else {
        setState(() {
          _isLoading = false;
          // _isEnabled = true;
        });
        _showMsg(
            "System encoutered an error code" + _response.statusCode.toString(),
            Colors.red);
      }
    } catch (e) {
      _showMsg("System encoutered an error.Kindly try again", Colors.red);
      setState(() {
        _isLoading = false;
        // _isEnabled = true;
      });
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

    _focusNodeFname.dispose();
    _focusPhone.dispose();
    _focusNodeEmail.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusNodeFname = FocusNode();
    _focusPhone = FocusNode();
    _focusNodeEmail = FocusNode();

    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
    _userid = ScopedModel.of<UserModel>(context, rebuildOnChange: true).userid;

    return Scaffold(
        backgroundColor: speedySurfacebackground,
        key: _addReferralScaffold,
        body: Container(
          decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Form(
              key: _formKeyReferral,
              child: ListView(
                padding: EdgeInsets.only(left: 20, right: 20),
                children: [
                  SizedBox(height: 30.0),
                  AccentColorOverride(
                      color: speedyBrown900,
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please  enter your friend name";
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
                              filled: true, labelText: 'Names '))),
                  SizedBox(height: 16.0),
                  InputDecorator(
                    decoration: InputDecoration(
                      border: cutcornersborder,
                    ),
                    child: AccentColorOverride(
                        color: speedyBrown900,
                        child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
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
                  ),
                  SizedBox(height: 16.0),
                  AccentColorOverride(
                      color: speedyBrown900,
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please  enter your friend phone number";
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
                              return "Please  enter your friend email";
                            } else
                              return null;
                          },
                          textInputAction: TextInputAction.done,
                          focusNode: _focusNodeEmail,
                          onFieldSubmitted: (term) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');

                            _focusNodeEmail.unfocus();

                            _validateReferralDetails();
                          },
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                              filled: true, labelText: 'Email '))),
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
                                        Text('Add ')
                                      ],
                                    )
                                  : Text('Add '),
                              elevation: 12.0,
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      _validateReferralDetails();
                                    })),
                      SizedBox(height: 14.0),
                    ],
                  )
                ],
              )),
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
