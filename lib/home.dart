import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedywriter/appscaffold.dart';
import 'package:speedywriter/appscaffold_two.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/ordering/orderingstagetwo.dart';
import 'package:speedywriter/presentation/custom_icons.dart';
import 'ordering/ordercalculations.dart';
import 'ordering/orderstrings.dart';

import 'ordering/ordermodel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/ordering/orderdetails.dart';
import 'package:speedywriter/common/routenames.dart';
import 'common/colors.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key key,
      @required this.orderStrings,
      @required this.model,
      @required this.orderCalculations})
      : super(key: key);

  final OrderCalculations orderCalculations;
  final OrderStrings orderStrings;
  final OrderModel model;

  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _lastSelected = 'TAB: 0';

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      if (index == 0) {
        Navigator.pushNamed(context, '/getquote');
      }
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

//==========End adding bottombar===========

  //Variable for calculating order cost
  double subjectCost = 1.0;
  double documentCost = 1.0;
  double urgencyCost = 1.15;
  double academicCost = 1.0;
  int spacing = 0;
  int pages = 1;

//End variables method

  //=============Class variables ======================================
  bool _issubjectTypeSelected = false;

  bool _isdocumenTypeSelected = false;

  bool _isnumberOfPagesSelected = false;

  bool _isurgencySelected = false;
  bool _isSpacingStyleSelected = false;
  bool _isacademicLevelSelected = false;

  String _urgency;
  String _numberofPages;
  String _documentType;
  String _subjectType;

  String _academicLevel;

  String _spacingStyle;

  FocusNode _focusNodeSubject;
  FocusNode _focusNodeDocument;
  FocusNode _focusNodepPages;
  FocusNode _focusNodeDeadline;
  FocusNode _focusNodeAcademicleve;
  FocusNode _focusNodeSpacing;
  FocusNode _focusNodeContinueButton;

  final GlobalKey<FormState> _formKeyHome = GlobalKey();
  //================End class variables===========================

//Moving to next focusn

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

//End next focus

  //Main method
  @override
  void initState() {
    // TODO: implement initState

    widget.model.calculateOrderCost(1.0, 1.0, 1.15, 1.0, 0, 1);

    super.initState();
  }

  @override
  void dispose() {
    _focusNodeSubject.dispose();
    _focusNodeDocument.dispose();
    _focusNodepPages.dispose();
    _focusNodeAcademicleve.dispose();
    _focusNodeSpacing.dispose();
    _focusNodeContinueButton.dispose();
    _focusNodeDeadline.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _focusNodeSubject = FocusNode();
    _focusNodeDocument = FocusNode();
    _focusNodepPages = FocusNode();
    _focusNodeDeadline = FocusNode();
    _focusNodeAcademicleve = FocusNode();
    _focusNodeSpacing = FocusNode();
    _focusNodeContinueButton = FocusNode();

    return AppScaffoldTwo(
      pageTitle: PageTitles.ordernow,
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKeyHome,
              child: ListView(
                children: <Widget>[
                  subjectArea(),
                  SizedBox(height: 12.0),
                  typeOfDocument(),
                  SizedBox(height: 12.0),
                  numberOfPages(),
                  SizedBox(height: 12.0),
                  urgency(),
                  SizedBox(height: 12.0),
                  acedemicLevel(),
                  SizedBox(height: 12.0),
                  spacingStyle(),
                  SizedBox(height: 12.0),
                  SizedBox(height: 12.0),
                  _placeOrderCard(),
                  SizedBox(height: 20.0),
                ],
              ),
            )),
      ),
    );
  }

//=======================Type of writing method=========================

  Widget subjectArea() {
    return ScopedModelDescendant<OrderModel>(
      builder: (context, child, model) {
        return Container(
          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.grey[50]),
          child: DropdownButtonFormField<String>(
            autofocus: true,
            autovalidate: true,
            focusNode: _focusNodeSubject,
            focusColor: speedyPurple400,
            iconSize: 40,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            isExpanded: true,
            items: widget.orderStrings.subjectArea
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) async {
              subjectCost = widget.orderCalculations.getSubjectAreaCost(
                  widget.orderStrings.subjectArea.indexOf(newValue));
              widget.model.calculateOrderCost(subjectCost, documentCost,
                  urgencyCost, academicCost, spacing, pages);

              _fieldFocusChange(context, _focusNodeSubject, _focusNodeDocument);

              setState(() {
                _issubjectTypeSelected = true;
                _subjectType = newValue;
              });
            },
            hint: Text('Select Subject Area'),
            value: _subjectType,
            validator: (value) =>
                value == null ? 'Please select your Subject' : null,
          ),
        );
      },
    );
  }

//===================End servcice type method==========================

//===============Method for type of work============================

  Widget typeOfDocument() {
    return ScopedModelDescendant<OrderModel>(builder: (context, model, child) {
      return Container(
        padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey[50]),
        child: DropdownButtonFormField<String>(
            focusNode: _focusNodeDocument,
            focusColor: speedyPurple400,
                     autovalidate: true,
            iconSize: 40,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            value: _isdocumenTypeSelected ? _documentType : null,
           
            hint: Text('Type of Document'),
             validator: (value) {
              if (value == null)
                return "Please select document type";
              else
                return null;
            },
            isExpanded: true,
            items: widget.orderStrings.documentType
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              documentCost = widget.orderCalculations.getDocumentTypeCost(
                  widget.orderStrings.documentType.indexOf(newValue));
              widget.model.calculateOrderCost(subjectCost, documentCost,
                  urgencyCost, academicCost, spacing, pages);

              _fieldFocusChange(context, _focusNodeDocument, _focusNodepPages);
              setState(() {
      
                _documentType = newValue;
                    _isdocumenTypeSelected = true;
                // print(documentCost);
                //print(  widget.orderStrings.documentType.indexOf(newValue));
               
              });
            }),
      );
    });
  }

//=========================End tye of work method==================

//===================Number of pages===========================

  Widget numberOfPages() {
    return ScopedModelDescendant<OrderModel>(builder: (context, child, model) {
      return Container(
        padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey[50]),
        child: DropdownButtonFormField<String>(
            focusNode: _focusNodepPages,
                     autovalidate: true,
            focusColor: speedyPurple400,
            iconSize: 40,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            isExpanded: true,
            value: _isnumberOfPagesSelected ? _numberofPages : null,
            hint: Text('Number of pages/words'),
            validator: (value) {
              if (value == null)
                return "Please select number of pages/words";
              else
                return null;
            },
            items: widget.orderStrings.pageNumbers
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              pages = widget.orderStrings.pageNumbers.indexOf(newValue) + 1;

              widget.model.calculateOrderCost(subjectCost, documentCost,
                  urgencyCost, academicCost, spacing, pages);
              _fieldFocusChange(context, _focusNodepPages, _focusNodeDeadline);

              setState(() {
                _numberofPages = newValue;
                _isnumberOfPagesSelected = true;
              });
            }),
      );
    });
  }

//=========End ====================

//============Begin Ur=gency method===========

  Widget urgency() {
    return ScopedModelDescendant<OrderModel>(
      builder: (context, child, model) {
        return Container(
          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.grey[50]),
          child: DropdownButtonFormField<String>(
              focusNode: _focusNodeDeadline,
                       autovalidate: true,
              focusColor: speedyPurple400,
              iconSize: 40,
              decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[50]))),
              isExpanded: true,
              hint: Text('Deadline'),
              value: _isurgencySelected ? _urgency : null,
              validator: (value) {
                if (value == null)
                  return "Please select Order urgency";
                else
                  return null;
              },
              items: widget.orderStrings.urgency
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                urgencyCost = widget.orderCalculations
                    .getUrgency(widget.orderStrings.urgency.indexOf(newValue));

                widget.model.calculateOrderCost(subjectCost, documentCost,
                    urgencyCost, academicCost, spacing, pages);
                _fieldFocusChange(
                    context, _focusNodeDeadline, _focusNodeAcademicleve);
                setState(() {
                  _isurgencySelected = true;
                  _urgency = newValue;
                });
              }),
        );
      },
    );
  }
  //=====End urgency method======

  Widget acedemicLevel() {
    return ScopedModelDescendant<OrderModel>(
      builder: (context, child, model) {
        return Container(
          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.grey[50]),
          child: DropdownButtonFormField<String>(
              focusNode: _focusNodeAcademicleve,
                       autovalidate: true,
              focusColor: speedyPurple400,
              iconSize: 40,
              decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[50]))),
              isExpanded: true,
              hint: Text('Academic Level'),
              value: _isacademicLevelSelected ? _academicLevel : null,
              validator: (value) {
                if (value == null)
                  return "Please select your academic level";
                else
                  return null;
              },
              items: widget.orderStrings.academicLevel
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                academicCost = widget.orderCalculations.getAcademicLevel(
                    widget.orderStrings.academicLevel.indexOf(newValue));
                widget.model.calculateOrderCost(subjectCost, documentCost,
                    urgencyCost, academicCost, spacing, pages);
                _fieldFocusChange(
                    context, _focusNodeAcademicleve, _focusNodeSpacing);
                setState(() {
                  _isacademicLevelSelected = true;
                  _academicLevel = newValue;
                });
              }),
        );
      },
    );
  }

//Language

  Widget spacingStyle() {
    return ScopedModelDescendant<OrderModel>(
      builder: (context, child, model) {
        return Container(
          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.grey[50]),
          child: DropdownButtonFormField<String>(
              focusNode: _focusNodeSpacing,
                       autovalidate: true,
              focusColor: speedyPurple400,
              iconSize: 40,
              decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[50]))),
              isExpanded: true,
              hint: Text('Select Spacing'),
              value: _isSpacingStyleSelected ? _spacingStyle : null,
              validator: (value) {
                if (value == null)
                  return "Please select Spacing i.e Double/Single";
                else
                  return null;
              },
              items: widget.orderStrings.spacingStyle
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                spacing =
                    widget.orderStrings.spacingStyle.indexOf(newValue) + 1;
                widget.model.calculateOrderCost(subjectCost, documentCost,
                    urgencyCost, academicCost, spacing, pages);
                _fieldFocusChange(
                    context, _focusNodeSpacing, _focusNodeContinueButton);
                setState(() {
                  _isSpacingStyleSelected = true;
                  _spacingStyle = newValue;
                });
              }),
        );
      },
    );
  }
//=======================Place order card bottom=======================

  Widget _placeOrderCard() {
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
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                  child: Material(
                      color: Theme.of(context).primaryColor,
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                        focusNode: _focusNodeContinueButton,
                        onPressed: () {
                          if (_formKeyHome.currentState.validate()) {
                            Navigator.pushNamed(
                                context, RouteNames.orderStageTwo,
                                arguments: OrderDetails(
                                    _documentType,
                                    _subjectType,
                                    _numberofPages,
                                    _academicLevel,
                                    _urgency,
                                    _spacingStyle));
                          }
                        },
                        minWidth: MediaQuery.of(context).size.width,
                        child: Text('Continue'),
                      )),
                ),
                SizedBox(height: 15),
              ],
            ),
          ));
    });
  }

//============================End place order card=========================

}
