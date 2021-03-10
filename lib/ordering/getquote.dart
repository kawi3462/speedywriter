import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/appscaffold_two.dart';

import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/common/cutcornerborders.dart';


import 'ordercalculations.dart';
import 'orderstrings.dart';

import 'ordermodel.dart';


class GetQuote extends StatefulWidget {
  GetQuote(
      {Key key,
      @required this.orderStrings,
      @required this.model,
      @required this.orderCalculations})
      : super(key: key);

  final OrderCalculations orderCalculations;
  final OrderStrings orderStrings;
  final OrderModel model;

  _GetQuoteState createState() => _GetQuoteState();
}

class _GetQuoteState extends State<GetQuote> {
//Start adding bottom nav==========
 final CutCornersBorder cutcornersborder=new CutCornersBorder();


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
  bool _showQuote = false;

  String _urgency;
  String _numberofPages;
  String _documentType;
  String _subjectType;

  String _academicLevel;

  String _spacingStyle;

  String title = "SPEEDY";
  final GlobalKey<FormState> _formKey = GlobalKey();
  //================End class variables===========================
  //Main method

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  return AppScaffoldTwo (
    index: 1,
     //   backgroundColor: Color(0xFFFAF0E6),
    pageTitle:PageTitles.getQuote,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
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
                /* spacingStyle(),
                SizedBox(height: 12.0),*/
                _priceDiscount(),
                SizedBox(height: 15.0)
               /* ScopedModelDescendant<OrderModel>(
                    builder: (context, child, model) {
                  return Material(
                      color: Theme.of(context).primaryColor,
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        minWidth: MediaQuery.of(context).size.width,
                        child: Text('Order Now'),
                      ));
                }),*/
             
              ],
            ),
          ),
        ),
      ),
    
    );
  }

//================================Discount calculation===================================
  Widget _priceDiscount() {
    return ScopedModelDescendant<OrderModel>(
      builder: (context, child, model) {
        return _isacademicLevelSelected
            ? Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Estimated Price:'),
                        SizedBox(width: 20),
                        Text(
                            "\$" +
                                model
                                    .roundDouble(
                                        (model.totalCost * 130 / 100), 2)
                                    .toString(),
                            style: TextStyle(
                                fontSize: 18,
                                decorationThickness: 3.0,
                                decoration: TextDecoration.lineThrough)),
                        SizedBox(width: 20),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 15, 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0)),
                              color: Colors.green),
                          child: Text("30 % Off"),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Your Order Cost:',
                          style: Theme.of(context).primaryTextTheme.display1,
                        ),
                        Text(
                          "\$" + model.totalCost.toString(),
                          style: Theme.of(context).primaryTextTheme.display1,
                        )
                      ],
                    )
                  ],
                ))
            : SizedBox(height: 12.0);
      },
    );
  }

//=======================Type of writing method=========================

  Widget subjectArea() {
    return ScopedModelDescendant<OrderModel>(
      builder: (context, child, model) {
        return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
          child: DropdownButtonFormField<String>(
              iconSize: 10,
              decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[50]))),
              isExpanded: true,
              hint: Text('Select Subject Area'),
              value: _issubjectTypeSelected ? _subjectType : null,
              validator: (value) {
                if (value == null)
                  return "Please select your Subject";
                else
                  return null;
              },
              items: widget.orderStrings.subjectArea
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                subjectCost = widget.orderCalculations.getSubjectAreaCost(
                    widget.orderStrings.subjectArea.indexOf(newValue));
                widget.model.calculateOrderCost(subjectCost, documentCost,
                    urgencyCost, academicCost, spacing, pages);

                setState(() {
                  _issubjectTypeSelected = true;
                  _subjectType = newValue;
                });
              }),
        );
      },
    );
  }

//===================End servcice type method==========================

//===============Method for type of work============================

  Widget typeOfDocument() {
    return ScopedModelDescendant<OrderModel>(builder: (context, model, child) {
      return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
        child: DropdownButtonFormField<String>(
            iconSize: 10,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            value: _isdocumenTypeSelected ? _documentType : null,
            validator: (value) {
              if (value == null)
                return "Please select document type";
              else
                return null;
            },
            hint: Text('Select Type of Document'),
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
              setState(() {
                _isdocumenTypeSelected = true;
                _documentType = newValue;
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
      return  InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
        child: DropdownButtonFormField<String>(
            iconSize: 10,
            decoration: InputDecoration(
                fillColor: Colors.grey[50],
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]))),
            isExpanded: true,
            value: _isnumberOfPagesSelected ? _numberofPages : null,
            hint: Text('Select Number of pages/words'),
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
        return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
          child: DropdownButtonFormField<String>(
              iconSize: 10,
              decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[50]))),
              isExpanded: true,
              hint: Text('Select Deadline'),
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
        return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
          child: DropdownButtonFormField<String>(
              iconSize: 10,
              decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[50]))),
              isExpanded: true,
              hint: Text('Select Academic Level'),
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
        return   InputDecorator(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
             
                  border: cutcornersborder,
                    
                    ),
          child: DropdownButtonFormField<String>(
              iconSize: 10,
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

                setState(() {
                  _isSpacingStyleSelected = true;
                  _spacingStyle = newValue;
                });
              }),
        );
      },
    );
  }
}
