
import 'package:flutter/material.dart';


import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';
import 'package:speedywriter/ordering/ordermodel.dart';
import 'package:flutter_rave/flutter_rave.dart';

import 'package:speedywriter/common/appbar.dart';








class CardPayment extends StatefulWidget {
  final OrderModel model;
  CardPayment({Key key, @required this.model}) : super(key: key);

  static const routeName = '/paypal';
  _CardPaymentState createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {

    final GlobalKey<ScaffoldState> _scaffoldCardState = new GlobalKey();


  double _totalCost;
  bool _isLoading;
      int _id ;

    String _email ;
    String _subject ;
    String _doc ;
    String _pages ;
    String _urgency ;

 //message dialg
 _showMsg(String msg) {
    final snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
   _scaffoldCardState.currentState.showSnackBar(snackbar);
  }

 //end 

  @override
  void initState() {
    // TODO: implement initState
    _totalCost = widget.model.totalCost;
    _isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final FinalOrderDetails _finalOrderDetails =
        ModalRoute.of(context).settings.arguments;
 _id = _finalOrderDetails.id;

  _email = _finalOrderDetails.email;
 _subject = _finalOrderDetails.subject;
 _doc = _finalOrderDetails.document;
  _pages = _finalOrderDetails.pages;
 _urgency = _finalOrderDetails.urgency;

    
    return Scaffold(
   //pageTitle: PageTitles.payPalPayment,
    
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.

        key:_scaffoldCardState,
      appBar: buildAppBar(PageTitles.cardpayments),
       body: Builder(
        builder: (context) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pay Me',
                  ),
                  FlatButton.icon(
                    onPressed: () {
                      _pay(context);
                    },
                    icon: Icon(Icons.email),
                    label: Text("Pay"),
                  ),
                ],
              ),
            )
      )
    );
  }

   _pay(BuildContext context) {
    final _rave = RaveCardPayment(
      isDemo: false,
      encKey: "70f70e52c71340ff2f8e1eba",
      publicKey: "FLWPUBK-7b9cdc0e38fabc1aab76061c77ea0200-X",
      transactionRef: _id.toString(),
      amount: 1.5,
      email: _email ,
      onSuccess: (response) {
        print("$response");
        print("Transaction Successful");
//implement payment sucess method here
        if (mounted) {
          Scaffold.of(context).showSnackBar(
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
        _showMsg("Transaction failed");
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
}