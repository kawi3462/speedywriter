import 'package:flutter/material.dart';
import 'package:speedywriter/appscaffold.dart';

import 'package:speedywriter/common/colors.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/ordering/ordermodel.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';


class MakePayment extends StatefulWidget {
  final OrderModel model;

  static const routeName = '/makepayment';
  MakePayment({Key key, @required this.model}) : super(key: key);

  _MakePaymentState createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
final GlobalKey <ScaffoldState> _scaffoldKey=GlobalKey();
  double _totalCost;

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
    final FinalOrderDetails finalOrderDetails =
        ModalRoute.of(context).settings.arguments;

    return AppScaffold(
      key: _scaffoldKey,
      pageTitle: PageTitles.makePayment,
      
       
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
                          child: Text(finalOrderDetails.id.toString())),
                    ]),
                    TableRow(children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text('Subject')),
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text(finalOrderDetails.subject))
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text('Document Type'),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text(finalOrderDetails.document),
                      )
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                        child: Text('Urgency'),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 12),
                          child: Text(finalOrderDetails.urgency))
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
            Container(
              child: Text('Do you have coupon code ?'),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 100, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    AccentColorOverride(
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Enter Here',
                            filled: true,
                            fillColor: Colors.grey[50]),
                      ),
                      color: speedyBrown900,
                    ),
                    Padding(padding: EdgeInsets.only(left:20),
                    
                    
                    child:OutlineButton(
                      splashColor: speedyPurple400,
                       textColor: speedyBrown900,
                       color: speedyPurple100,
                       hoverColor: speedyPurple200,
            
                        borderSide: BorderSide(
                          width: 4.0,
                            color: speedyPurple100, style: BorderStyle.solid),
                        onPressed: (){

                          _showMsg("Out team of developers are working to add this functionality.Keep updating your app whenever we have a new version");




                        }
                        ,child: Text('Apply'),
                        )
                    
                    )
                  ]),
            )
          ]),
        ));
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
