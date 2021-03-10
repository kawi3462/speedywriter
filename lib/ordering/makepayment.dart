import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:speedywriter/presentation/custom_icons.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/ordering/ordermodel.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';


import 'package:speedywriter/common/routenames.dart';

import 'package:speedywriter/common/colors.dart';

import 'package:flutter_rave/flutter_rave.dart';
import 'package:speedywriter/account/usermodel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:speedywriter/common/drawer.dart';



class MakePayment extends StatefulWidget {
  final OrderModel model;

  static const routeName = '/makepayment';
  MakePayment({Key key, @required this.model}) : super(key: key);

  _MakePaymentState createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
final GlobalKey <ScaffoldState> _scaffoldKey=GlobalKey();
  double _totalCost;
     int _id ;

    String _email ;
    String _subject ;
    String _doc ;
    String _pages ;
    String _urgency ;
    String _token;

  @override
  void initState() {
    // TODO: implement initState
    _totalCost = widget.model.totalCost;

    super.initState();
  }

    _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
_scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {

 _token=   ScopedModel.of<UserModel>(context, rebuildOnChange: false).token;

    final FinalOrderDetails _finalOrderDetails =
        ModalRoute.of(context).settings.arguments;

        _id = _finalOrderDetails.id;

  _email = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user.email;
 _subject = _finalOrderDetails.subject;
 _doc = _finalOrderDetails.document;
  _pages = _finalOrderDetails.pages;
 _urgency = _finalOrderDetails.urgency; 

   final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;
    return Row(children: [
      if (!displayMobileLayout)
        const SimpleDrawer(
          permanentlyDisplay: true,
        ),
        Expanded(
          child:Scaffold(
   
            key: _scaffoldKey,
            appBar: AppBar(
              // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
              automaticallyImplyLeading: displayMobileLayout,
              title: Text(
                PageTitles.makePayment,
              ),
            ),
            drawer: displayMobileLayout
                ? const SimpleDrawer(
                    permanentlyDisplay: false,
                  )
                : null,
       
        body: SafeArea(
          child: ListView(children: [
            SizedBox(height: 20.0),
            Container(
              child: Text(
                'Order Details:',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Table(
                  defaultColumnWidth: FlexColumnWidth(1.0),
                  border: TableBorder.all(),
                  children: [
                    TableRow(decoration: BoxDecoration(), children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text('Order ID'),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text(_id.toString())),
                    ]),
                    TableRow(children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text('Subject')),
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text(_subject))
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text('Document Type'),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text(_doc),
                      )
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text('Urgency'),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text(_urgency))
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text('Total Cost'),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text(_totalCost.toString()))
                    ])
                  ]),
            ),

Text('Pay with Paypal,Card Or request Paypal Invoice',  style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),),
               Container(
              padding:EdgeInsets.all(5),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
          children: [


             Expanded(
                    flex: 2,
                    child:
                      Material(
                      
                      color:speedyPurple100, 
                      child:
 InkWell(
                    hoverColor: speedyPurple200,
                    child: Ink(
                        padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: speedySurfaceWhite,
                          width:2.0,
                        )


                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(MyFlutterApp.cc_paypal),
                
            
                          SizedBox(
                            width: 10,
                          ),
                             Text('Paypal'),
                        ],
                      ),
                    ),
                    onTap: () {
                       Navigator.pushNamed(
                                    context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        _id,
                              
                                        _subject,
                                        _doc,
                                        _pages,
                                        _urgency,
                                      ));
                                      

                    },
                  ))),
                  
        

  Expanded(
                    flex: 2,
                    child:
                    Material(
                      
                      color:speedyPurple100, 
                      child:
 
   InkWell(
 
                
    splashColor: speedyPurple400,
                    hoverColor: speedyPurple200,
                    child: Ink(
                      padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: speedySurfaceWhite,
                          width:2.0,
                        )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(MyFlutterApp.cc_visa),
                           SizedBox(
                            width: 10,
                          ),
                Icon(
                
                  
                  MyFlutterApp.cc_mastercard),
            
                          SizedBox(
                            width: 10,
                          ),
                             Text('Card'),
                        ],
                      ),
                    ),
                    onTap: () {
                          _pay(context);
                    },
                  ))),

     Expanded(
                    flex: 2,
                    child:
                      Material(
                      
                      color:speedyPurple100, 
                      child:
 InkWell(
                    hoverColor: speedyPurple200,
                    child: Ink(
                        padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: speedySurfaceWhite,
                          width:2.0,
                        )


                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(MyFlutterApp.cc_paypal),
                
            
                          SizedBox(
                            width: 10,
                          ),
                             Text('Invoice'),
                        ],
                      ),
                    ),
                    onTap: () {
                       Navigator.pushNamed(
                                    context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        _id,
                            
                                        _subject,
                                        _doc,
                                        _pages,
                                        _urgency,
                                      ));
                                      

                    },
                  ))),

           

              ]
              )
              
               )
           
            
          ]),
        ))



        )



    ]
    );
     
  }

_pay(BuildContext context) {


//ScopedModel.of<UserModel>(context, rebuildOnChange: true).enckey,
//ScopedModel.of<UserModel>(context, rebuildOnChange: true).publickey,
  
    final _rave = RaveCardPayment(
      isDemo: false,
         encKey: "70f70e52c71340ff2f8e1eba",
      publicKey: "FLWPUBK-7b9cdc0e38fabc1aab76061c77ea0200-X",
      transactionRef: _id.toString(),
      amount: _totalCost,
      email: _email ,
      onSuccess: (response) {
        //update order payment 
      _editOrderPayment(_token,_id.toString());
      //end order update payment

        print("$response");
        print("Transaction Successful");
//implement payment sucess method here
        if (mounted) {
       _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("Transaction Sucessful!"),
              backgroundColor: Colors.green,
              duration: Duration(
                seconds: 5,
              ),
            ),
          );
        }
      },
      onFailure: (err) {

          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("Transaction failed"),
              backgroundColor: Colors.redAccent,
              duration: Duration(
                seconds: 5,
              ),
            ),
          );
      
        print("$err");

        print("Transaction failed");
      },
      onClosed: () {
        _showMsg("Transaction closed");
        print("Transaction closed");
      },
      context: context,
    );

    _rave.process();
  }
 void _editOrderPayment( String token, String id) async {
  
  Map _data = {
        'status':'Waiting Approval',
        'payment':'Paid',
    
      };

      String _orderJson = jsonEncode(_data);


    try {
      var apiUrl = '/updateorderpayment/' + id;

      var response = await  Network().submitData(_orderJson, apiUrl, token);

      if (response.statusCode == 200) {
        
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .loadUserOrders();
      }
      else{
 _showMsg("Payment not updated");

      }
      }
         catch (e) {
    
      _showMsg("Payment not updated");
    }

 }



}

class AccentColorOverride extends StatelessWidget {
  final Color color;
  final Widget child;

  AccentColorOverride({
    this.color,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Theme(
        child: child,
        data: Theme.of(context)
            .copyWith(accentColor: color, brightness: Brightness.dark));
  }
}
