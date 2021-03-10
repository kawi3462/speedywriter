import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/manageorders/editorderdetails.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/common/routenames.dart';

import 'package:speedywriter/common/appbar.dart';
import 'package:speedywriter/common/cutcornerborders.dart';
import 'package:speedywriter/common/colors.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';
import 'package:speedywriter/serializablemodelclasses/user.dart';

import 'package:speedywriter/network_utils/api.dart';

import 'package:speedywriter/account/usermodel.dart';

class EditOrder extends StatefulWidget {
  // static const routeName = '/editorder';

  EditOrder({
    Key key,
  }) : super(key: key);

  _EditOrderState createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
  //Order details passed from previous order page==========
  User _user;

  final GlobalKey<ScaffoldState> _scaffoldkeyEditOrder = GlobalKey();
  // final Network _network = Network();
  bool _isLoading = false;
  String _checked = null;
  bool _isMaterialsNotChecked = false;
  EditOrderDetails _details, _newdetails;
  final CutCornersBorder cutcornersborder = new CutCornersBorder();

//==============end  variables================
  _showMsg(String msg, Color color) {
    final snackbar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldkeyEditOrder.currentState.showSnackBar(snackbar);
  }

  final GlobalKey<FormState> _formKeyEditOrder = GlobalKey();
  String _topic;
  String _writingStyle;
  String _prefferedLanguage;
  String _instructions;
  String _email;
  String _token;
  bool _iswritingStyleSelected = false;
  bool _isprefferedLanguageSelected = false;

  TextEditingController _topicController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();

  FocusNode _focusNodeTopic;
  FocusNode _focusNodeWritingStyle;
  FocusNode _focusNodePrefferedLanguage;
  FocusNode _focusNodeInstructions;
  FocusNode _focusNodeSubmitButton;

  //Moving to next focusn

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

//End next focus

  //validating order details before submitting
  void _validateOrderDetails() {
    if (_formKeyEditOrder.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      _topic = _topicController.text;
      _instructions = _instructionsController.text;

      // Map _data = {
      //   'description': _instructions,
      //   'langstyle': _prefferedLanguage,
      //   'topic': _topic,
      //   'style': _writingStyle,
      // };

      // String _orderJson = jsonEncode(_data);

      _submitOrder(_token);
    }
  }

  //End order validation

  void _submitOrder(String token) async {


    try {
      var apiUrl = "/user/"+_user.id.toString() +"/orders/" +_details.id +
          "?description=" +
          _instructions +
          "&langstyle=" +
          _prefferedLanguage +
          "&topic=" +
          _topic +
          "&style=" +
          _writingStyle;

      // var apiUrl ="/user/27/orders/49?description=eric mutua&langstyle=english&topic=english&style=APA";
      var response = await Network().updateData(apiUrl,_token);

      if (response.statusCode == 200) {
   
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .loadUserOrders();

        _showMsg("Order Edited successfuly", Colors.green);
        //Load user orders after adding a new order
      
        // //End loading user orders

        setState(() {
          _isLoading = false;
        });

        // Navigator.pushNamed(context, RouteNames.uploadMaterial,
        //     arguments: FinalOrderDetails(
        //       jsonResponse['id'],
        //       jsonResponse['subject'],
        //       jsonResponse['document'],
        //       jsonResponse['pages'],
        //       jsonResponse['urgency'],
        //     ));
      }
       else if (response.statusCode == 422) {
        // jsonResponse = jsonDecode(response.body);

        //  print(jsonResponse);

        setState(() {
          _isLoading = false;
        });

        _showMsg(
            "Order Not submitted:Error code" + response.statusCode.toString(),
            Colors.red);
      } else {
        //   jsonResponse = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
        });

        _showMsg(
            "Order Not submitted:Error code" + response.statusCode.toString(),
            Colors.red);
      }
    } 
    catch (e) {
   
      setState(() {
        _isLoading = false;
      });
      _showMsg("Cannot connect with the  server", Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    _topicController.clear();
    _instructionsController.clear();
    _focusNodeTopic.dispose();
    _focusNodeWritingStyle.dispose();
    _focusNodePrefferedLanguage.dispose();
    _focusNodeInstructions.dispose();
    _focusNodeSubmitButton.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _user = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user;
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;
    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
    _email = ScopedModel.of<UserModel>(context, rebuildOnChange: true).email;
    _details = ModalRoute.of(context).settings.arguments;

    _focusNodeTopic = FocusNode();
    _focusNodeWritingStyle = FocusNode();
    _focusNodePrefferedLanguage = FocusNode();
    _focusNodeInstructions = FocusNode();
    _focusNodeSubmitButton = FocusNode();

    return Row(children: [
      if (!displayMobileLayout)
        const SimpleDrawer(
          permanentlyDisplay: true,
        ),
      Expanded(
          child: Scaffold(
              key: _scaffoldkeyEditOrder,
              appBar: AppBar(
                // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
                automaticallyImplyLeading: displayMobileLayout,
                title: Text(
                  PageTitles.editorder,
                ),
              ),
              drawer: displayMobileLayout
                  ? const SimpleDrawer(
                      permanentlyDisplay: false,
                    )
                  : null,
              body: SafeArea(
                  child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Form(
                          key: _formKeyEditOrder,
                          child: ListView(children: <Widget>[
                            writingStyle(),
                            SizedBox(height: 12.0),
                            prefferedLanguage(),
                            SizedBox(height: 12.0),
                            Container(
                                decoration:
                                    BoxDecoration(color: Colors.grey[50]),
                                child: AccentColorOverride(
                                  child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      focusNode: _focusNodeTopic,
                                      autovalidate: true,
                                      onFieldSubmitted: (term) {
                                        _fieldFocusChange(
                                            context,
                                            _focusNodeTopic,
                                            _focusNodeInstructions);
                                      },
                                      controller: _topicController,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Please enter your topic";
                                        } else
                                          return null;
                                      },
                                      onSaved: (String value) {
                                        _topic = value;
                                      },
                                      decoration: InputDecoration(
                                          filled: true,
                                          labelText: 'Enter Topic')),
                                  color: speedyBrown900,
                                )),
                            SizedBox(height: 12.0),
                            Container(
                                decoration:
                                    BoxDecoration(color: Colors.grey[50]),
                                child: AccentColorOverride(
                                  child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      focusNode: _focusNodeInstructions,
                                      autovalidate: true,
                                      onFieldSubmitted: (term) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      minLines: 3,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      controller: _instructionsController,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Please fill order Instructions ";
                                        } else
                                          return null;
                                      },
                                      decoration: InputDecoration(
                                          filled: true,
                                          labelText: 'Enter Instructions')),
                                  color: speedyBrown900,
                                )),
                            SizedBox(height: 12.0),
                            _placeOrderCard(),
                            SizedBox(height: 20.0),
                          ]))))))
    ]);
  }

//===========Writing style method=============
  Widget writingStyle() {
    return InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          border: cutcornersborder,
        ),
        child: DropdownButtonFormField(
            focusNode: _focusNodeWritingStyle,
            autofocus: true,
            autovalidate: true,
            iconSize: 12,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            hint: Text('Writing style'),
            value: _iswritingStyleSelected ? _writingStyle : null,
            validator: (value) {
              if (value == null) {
                return "Please select writing style";
              } else
                return null;
            },
            isExpanded: true,
            items: <String>[
              'APA',
              'MLA',
              'Turabian',
              'Chicago',
              'Harvard',
              'Oxford',
              'Vancouver',
              'CBE',
              'Other'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
            onChanged: (String value) {
              _fieldFocusChange(
                  context, _focusNodeWritingStyle, _focusNodePrefferedLanguage);

              setState(() {
                _writingStyle = value;
                _iswritingStyleSelected = true;
              });
            }));
  }

  Widget prefferedLanguage() {
    return InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          border: cutcornersborder,
        ),
        child: DropdownButtonFormField(
            focusNode: _focusNodePrefferedLanguage,
            autovalidate: true,
            isExpanded: true,
            hint: Text("Preferred Language"),
            iconSize: 12,
            validator: (value) {
              if (value == null) {
                return "Please select preferred language";
              } else
                return null;
            },
            value: _isprefferedLanguageSelected ? _prefferedLanguage : null,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            items: <String>['English(U.S)', 'English(U.K)']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
            onChanged: (String value) {
              _fieldFocusChange(
                  context, _focusNodePrefferedLanguage, _focusNodeTopic);

              setState(() {
                _isprefferedLanguageSelected = true;
                _prefferedLanguage = value;
              });
            }));
  }

//=======================Place order card bottom=======================

  Widget _placeOrderCard() {
    return Card(
        elevation: 2.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        style: TextStyle(color: Colors.black),
                        text:
                            'By clicking "Submit Order" I agree to Lastminutessay '),
                    TextSpan(
                        style: TextStyle(color: Colors.blue),
                        text: 'Terms of Service'),
                  ]),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                child: Material(
                    color: Theme.of(context).primaryColor,
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              _validateOrderDetails();
                            },
                      minWidth: MediaQuery.of(context).size.width,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                CircularProgressIndicator(),
                                Text('Submitting')
                              ],
                            )
                          : Text('Submit '),
                    )),
              ),
              SizedBox(height: 15),
            ],
          ),
        ));
  }

//============================End place order card=========================

}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride(
      {Key key, @required this.color, @required this.child})
      : super(key: key);
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context)
          .copyWith(accentColor: color, brightness: Brightness.dark),
    );
  }
}
