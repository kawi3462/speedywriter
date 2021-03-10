import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/manageorders/myorderseriazable.dart';

import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/common/routenames.dart';

import 'ordermodel.dart';
import 'package:speedywriter/common/appbar.dart';
import 'package:speedywriter/common/colors.dart';
import 'package:speedywriter/ordering/orderdetails.dart';
import 'package:speedywriter/serializablemodelclasses/order.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'finalorderdetails.dart';
import 'package:speedywriter/common/cutcornerborders.dart';

import 'package:speedywriter/account/usermodel.dart';

class OrderStageTwo extends StatefulWidget {
  final OrderModel model;

  OrderStageTwo({Key key, @required this.model}) : super(key: key);

  _OrderStateTwoState createState() => _OrderStateTwoState();
}

class _OrderStateTwoState extends State<OrderStageTwo> {
  //Order details passed from previous order page==========
  Order order;
  OrderDetails _details;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey();
  final Network _network = Network();
  bool _isLoading = false;
  String _checked = null;
  bool _isMaterialsNotChecked = false;
  String _userid;
   final CutCornersBorder cutcornersborder=new CutCornersBorder();

//==============end  variables================
  _showMsg(String msg,Color color) {
    final snackbar = SnackBar(
      backgroundColor:color,
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

//Total from model
  String total;

//
//Moving to next focusn

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

//End next focus

  final GlobalKey<FormState> _formKeyOrderStatetwo = GlobalKey();
  String _topic;
  String _writingStyle;
  String _prefferedLanguage;
  String _instructions;

  String _token;
  bool _iswritingStyleSelected = false;
  bool _isprefferedLanguageSelected = false;

  TextEditingController _topicController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();
  //Focus nodes
  FocusNode _focusNodeTopic;
  FocusNode _focusNodeWritingStyle;
  FocusNode _focusNodePrefferedLanguage;
  FocusNode _focusNodeInstructions;
  FocusNode _focusNodeSubmitButton;

  //End focus nodes

  //validating order details before submitting
  void _validateOrderDetails() {
    if (_formKeyOrderStatetwo.currentState.validate()) {
      if (_checked == null) {
        setState(() {
          _isMaterialsNotChecked = true;
        });
      } else {
        //  Navigator.pushNamed(context, '/orderstagetwo');

        setState(() {
          _isLoading = true;
        });

        _topic = _topicController.text;
        _instructions = _instructionsController.text;

     
        order = Order(
            _topic,
            _details.subjectType,
            _details.numberofPages,
            _writingStyle,
            _details.documentType,
            _details.academicLevel,
            _prefferedLanguage,
            _details.urgency,
            _details.spacingStyle,
              total,
            _instructions,
            "Pending payment",
            "Pending");

        String orderJson = jsonEncode(order);

        //   print(orderJson);
        _submitOrder(orderJson, _token);
        //  print("========================token ==============");

        // print(_token);
        //  print( _email,);
      }
    }
  }

  //End order validation

  void _submitOrder(String orderJson, String token) async {
    var jsonResponse;

    try {
      var apiUrl = "/user/"+_userid+"/orders";

      var response = await _network.submitData(orderJson, apiUrl, token);
   
      if (response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body)['data'];

     Myorder _myorder= Myorder(
        jsonResponse['id'],
 
 jsonResponse['topic'],
 jsonResponse['subject'],
 jsonResponse['pages'],
  jsonResponse['style'],
 jsonResponse['document'],
  jsonResponse['academiclevel'],
     jsonResponse['langstyle'],
 jsonResponse['urgency'],
 jsonResponse['spacing'],

          jsonResponse['total'],
      jsonResponse['description'],
      jsonResponse['status'],
 jsonResponse['payment'],
jsonResponse['created_at'],

     );




        //   _showMsg("Order submitted successfuly");
        //Load user orders after adding a new order
    // ScopedModel.of<UserModel>(context, rebuildOnChange: true).addNewOrderToPendingOrders(_myorder);

      //  ScopedModel.of<UserModel>(context, rebuildOnChange: true)
           // .loadUserOrders();
        //End loading user orders
    
        

        setState(() {
          _isLoading = false;
        });

        if (_checked == 'Yes') {


          Navigator.pushNamed(context, RouteNames.uploadMaterial,
              arguments: FinalOrderDetails(
                  jsonResponse['id'],
       
                jsonResponse['subject'],
                jsonResponse['document'],
                jsonResponse['pages'],
                jsonResponse['urgency'],
              ));
        } 
        
        else {
ScopedModel.of<UserModel>(context, rebuildOnChange: true).loadUserOrders();

          Navigator.pushNamed(context, RouteNames.makepayments,
              arguments: FinalOrderDetails(
                  jsonResponse['id'],
         
                jsonResponse['subject'],
                jsonResponse['document'],
                jsonResponse['pages'],
                jsonResponse['urgency'],
              ));
        }
      } 
      else if (response.statusCode == 422) {
      
   

        setState(() {
          _isLoading = false;
        });

        _showMsg("Order Not submitted.Try again please:Error code 422",Colors.red);
      } 
      else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
        });

        _showMsg("Unauthenticated:Server not responding:Error code 401",Colors.red);
      }
       else {
        //   jsonResponse = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
        });
     
   
        _showMsg("Order Not submitted.We encountered Error Code "+response.statusCode.toString(),Colors.red);
      }
    } 
    catch (e) {
    
      setState(() {
        _isLoading = false;
      });
      _showMsg("Server  error",Colors.red);
    }
  }

  @override
  void initState() {
    total = widget.model.totalCost.toString();
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
    _focusNodeTopic = FocusNode();
    _focusNodeWritingStyle = FocusNode();
    _focusNodePrefferedLanguage = FocusNode();
    _focusNodeInstructions = FocusNode();
    _focusNodeSubmitButton = FocusNode();

    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
    _userid = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user.id.toString();
    _details = ModalRoute.of(context).settings.arguments;
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;
    return Row(children: [
      if (!displayMobileLayout)
        const SimpleDrawer(
          permanentlyDisplay: true,
        ),
      Expanded(
          child: Scaffold(
              key: _scaffoldkey,
              appBar: buildAppBar(PageTitles.orderingstagetwo),
              body: SafeArea(
                  child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Form(
                          key: _formKeyOrderStatetwo,
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
                                      autovalidate: false,
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
                                      autovalidate: false,
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
                            checkBoxes(),
                            SizedBox(height: 12.0),
                            _placeOrderCard(_details),
                            SizedBox(height: 20.0),
                          ]
                          )
                          )
                          )
                          )
                          )
                          )
    ]);
  }

//===========Writing style method=============
  Widget writingStyle() {
    return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
        child: DropdownButtonFormField(
            focusNode: _focusNodeWritingStyle,
            autofocus:false,
            autovalidate: true,
               iconSize: 10,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))
                    ),
         



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
            onChanged: (value) {
              _fieldFocusChange(
                  context, _focusNodeWritingStyle, _focusNodePrefferedLanguage);

              setState(() {
                _iswritingStyleSelected = true;
                  _writingStyle = value;
              });
            }
            ,
                 
hint:  Text('Select Writing style'),
            value: _writingStyle,
            validator: (value) =>
                value == null ? 'Please select writing style' : null,

            
            )
            
            
            
            );
  }

  Widget prefferedLanguage() {
    return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
        child: DropdownButtonFormField(
            focusNode: _focusNodePrefferedLanguage,
            autovalidate: true,
            isExpanded: true,
            hint: Text("Select Preferred Language"),
            iconSize: 10,
            validator: (value) {
              if (value == null) {
                return "Please select preferred language";
              } else
                return null;
            },
            value:  _prefferedLanguage ,
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

  Widget _placeOrderCard(OrderDetails details) {
    return ScopedModelDescendant<OrderModel>(builder: (context, child, model) {
      return Card(
          elevation: 2.0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: Center(
                        child: Text(
                      "Order Cost",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ))),
                ListTile(
                  isThreeLine: false,
                  title: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black),
                        text: 'Total:'),
                  ])),
                  trailing: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black),
                        text: 'USD\$ '),
                    TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black),
                        text: model
                            .roundDouble((model.totalCost * 130 / 100), 2)
                            .toString()),
                  ])),
                ),
                ListTile(
                    isThreeLine: false,
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            style: TextStyle(color: Colors.black),
                            text: 'Discount:'),
                        TextSpan(
                            style: TextStyle(color: Colors.blue),
                            text: '  30%'),
                      ]),
                    ),
                    trailing: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                          text: 'USD\$ '),
                      TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                          text: model
                              .roundDouble((model.totalCost * 30 / 100), 2)
                              .toString()),
                    ]))),
                ListTile(
                    isThreeLine: false,
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            style: TextStyle(color: Colors.black),
                            text: 'TurnitIn Report:'),
                        TextSpan(
                            style: TextStyle(color: speedyPurple400),
                            text: ' Free '),
                        TextSpan(
                          style: TextStyle(
                            color: speedyPurple400,
                            decoration: TextDecoration.lineThrough,
                          ),
                          text: ' :(USD\$ 10.0)',
                        ),
                      ]),
                    ),
                    trailing: Text(
                      'USD\$ 0.0',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
                ListTile(
                    isThreeLine: false,
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            style: TextStyle(color: Colors.black),
                            text: 'Title page +'),
                        TextSpan(
                            style: TextStyle(color: Colors.black),
                            text: 'Bibliography'),
                        TextSpan(
                            style: TextStyle(color: speedyPurple400),
                            text: ' :Free'),
                        TextSpan(
                          style: TextStyle(
                            color: speedyPurple400,
                            decoration: TextDecoration.lineThrough,
                          ),
                          text: ' :(USD\$ 10.0)',
                        ),
                      ]),
                    ),
                    trailing: Text(
                      'USD\$ 0.0',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
                Divider(
                  height: 5,
                  color: speedyBrown900,
                  thickness: 2,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                    isThreeLine: false,
                    title: Text(
                      "Total Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                          text: 'USD\$ '),
                      TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                          text: model.totalCost.toString()),
                    ]))),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(color: Colors.black),
                          text:
                              'By clicking "Submit Order" I agree to Speedywriter '),
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
                        focusNode: _focusNodeSubmitButton,
                        onPressed: _isLoading
                            ? null
                            : () async {
                                _validateOrderDetails();
                              },
                        minWidth: MediaQuery.of(context).size.width,
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  Text('Submitting Order')
                                ],
                              )
                            : Text('Submit Order'),
                      )),
                ),
                SizedBox(height: 15),
              ],
            ),
          ));
    });
  }

//============================End place order card=========================

  //Check boxes for confirming
  Widget checkBoxes() {
    return Container(
        padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        decoration: _isMaterialsNotChecked
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: speedyErrorRed,
                  width: 1.0,
                ))
            : null,
        child: Wrap(
          children: <Widget>[
            Text(
              'Do you have reference materials for this order that you need to attach ?',
              style: TextStyle(
                color: _isMaterialsNotChecked ? speedyErrorRed : null,
              ),
            ),
            RadioButtonGroup(
              activeColor: Theme.of(context).primaryColor,
              orientation: GroupedButtonsOrientation.HORIZONTAL,
              labels: <String>['Yes', 'No'],
              picked: _checked,
              onSelected: (String selected) {
                setState(() {
                  _isMaterialsNotChecked = false;
                });
                _checked = selected;
              },
            ),
          ],
        ));
  }
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
