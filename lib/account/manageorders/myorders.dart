import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speedywriter/account/manageorders/editorderdetails.dart';

import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';

import 'package:speedywriter/account/usermodel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'myorderseriazable.dart';
import 'package:speedywriter/ordering/ordermodel.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:speedywriter/network_utils/api.dart';

import 'package:flutter/gestures.dart';
import 'package:speedywriter/common/colors.dart';

import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/presentation/custom_icons.dart';

class MyOrders extends StatefulWidget {
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
//Orders
  Myorder _myorder;
  List<Myorder> _pending;
  List<Myorder> _waiting;
  List<Myorder> _progress;
  List<Myorder> _revision;
  List<Myorder> _completed;
  bool _isDeleting = false;
  bool _isSending = false;
  bool _isTablet = false;
  bool orderHasFiles;

  String _token;
  String _userid;
  //Start adding bottom nav==========

  int index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

//Download completed paper

  void _downLoadCompletedPaper(String id) async {
    var apiUrl = "/order/" + id + "/download";
    try {
      var _response = await Network().getUserData(apiUrl, _token);

      //   Map _responseMap = jsonDecode(_response.body);
      if (_response.statusCode == 200) {
        setState(() {
          _isSending = false;
        });
        _showMsg(
            "Your Order has been sent to your Email Address.Go see the attached files.",
            Colors.green);
      }

     else  if (_response.statusCode == 404) {
        setState(() {
          _isSending = false;
        });

         _showMsg(
            "Order files not found.Chat Admin.",
            Colors.red);
      
      }
       else {
        setState(() {
          _isSending = false;
        });
        _showMsg(
            "Error Occured while retrieving your order files.Try again please.",
            Colors.red);
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      print(e);
    }
  }

//End download completed paper

  _showMsg(String msg, Color color) {
    final snackbar = SnackBar(
      backgroundColor: color,
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _scaffoldState.currentState.showSnackBar(snackbar);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    setState(() {
      if (_width > 1000) {
        _isTablet = true;
      }
    });

    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;
    ScopedModel.of<UserModel>(context, rebuildOnChange: true).loadUserOrders();
    orderHasFiles =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles;

    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
    _userid = ScopedModel.of<UserModel>(context, rebuildOnChange: true).userid;

    ScopedModel.of<UserModel>(context, rebuildOnChange: true).loadUserOrders();
    _pending =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).pendingOrders;
    _waiting =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).waitingOrders;
    _progress = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .assignedOrders;

    _revision = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .revisionOrders;
    _completed = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .completedOrders;
    // _ordermaterial = ScopedModel.of<UserModel>(context, rebuildOnChange: true).ordermaterials;

    return Row(
      children: [
        if (!displayMobileLayout)
          const SimpleDrawer(
            permanentlyDisplay: true,
          ),
        Expanded(
            child: DefaultTabController(
          length: 4,
          child: Scaffold(
            key: _scaffoldState,
            backgroundColor: Color(0xFFFAF0E6),
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: "Pending ", icon: Icon(Icons.warning)),
                  Tab(text: "In Progress ", icon: Icon(Icons.autorenew)),
                  Tab(text: "Revision ", icon: Icon(Icons.assignment_returned)),
                  Tab(
                      text: "Completed",
                      icon: Icon(Icons.assignment_turned_in)),
                ],
              ),

              // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
              automaticallyImplyLeading: displayMobileLayout,
              title: Text(
                PageTitles.myorders,
              ),
            ),
            drawer: displayMobileLayout
                ? const SimpleDrawer(
                    permanentlyDisplay: false,
                  )
                : null,
            body: TabBarView(children: [
              pendingOrders(),
              progressOrders(),
              revisionOrders(),
              completedOrders(),
            ]),
          ),
        ))
      ],
    );
  }

//Confirm order deletion first

  _showUserStatusDialog(Myorder _myorder) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: "Confirm deletion of Order #" + _myorder.id.toString(),
      desc:
          "Your about to delete order this order.Kindly confirm.Click OK to delete or Cancel to stop deletion ",
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _deleteOrder(_myorder);
      },
    )..show();
  }

//End order deletion  confirmation

//Delete order method
  void _deleteOrder(Myorder _myorder) async {
    setState(() {
      _isDeleting = true;
    });

    Navigator.of(context, rootNavigator: true).pop(context);

    String _apiUrl = "/user/" + _userid + "/orders/" + _myorder.id.toString();

    try {
      var _response = await Network().deleteData(_apiUrl, _token);

      if (_response.statusCode == 200) {
        setState(() {
          _pending.remove(_myorder);
          _isDeleting = false;
        });
      } else if (_response.statusCode == 404) {
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .pendingOrders
            .remove(_myorder.id);
        setState(() {
          _pending.remove(_myorder);
          _isDeleting = false;
        });
      } else if (_response.statusCode == 403) {
        setState(() {
          _isDeleting = false;
        });

        _showMsg("This action is unauthorized.You cannot delete the order",
            Colors.red);
      } else {
        setState(() {
          _isDeleting = false;
        });
        print(_response.statusCode.toString());
        print(_response.body.toString());
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      print(e);
    }
  }

//View order materials and delete  some of them

//End viewing order materials
//Start view for completed orders

  completedOrdersView(Myorder _myorder) {
    bool _orderHasFiles = false;
    if (_myorder.materials.length > 0) {
      _orderHasFiles = true;
      print(_myorder.materials);

      ScopedModel.of<UserModel>(context, rebuildOnChange: true)
          .addOrderMaterials(_myorder.materials);
    }

    return AwesomeDialog(
      useRootNavigator: true,
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order #",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.id.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text("Details",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Text("============================"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Subject:",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.black),
                ),
                SizedBox(width: 10),
                Text(_myorder.subject),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Pages/Words:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.pages),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Delivery Time :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.urgency),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Total Cost :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.total),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Writing Style:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Document Type:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.document),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Academic Level:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.academiclevel),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Language :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.langstyle),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Line Spacing :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.spacing),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order Status:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.status),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Payment Status:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.payment),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Date Ordered:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.created_at),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Topic:",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.black)),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _myorder.topic,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Instructions:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _myorder.description,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Reference materials:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            _orderHasFiles
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: 'View Attached files',
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                showModalBottomSheet(
                                    isDismissible: true,
                                    useRootNavigator: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ViewOrderFilesBottomSheet(
                                        myorder: _myorder,
                                        token: _token,
                                      );
                                    });
                              },
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                      ),
                      SizedBox(height: 50),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Reference materials attached",
                      ),
                    ],
                  ),
          ],
        )),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {},
    )..show();
  }

//End view for completed orders

//Start view for .in progress revision and completed orders

  progressRevisionOrdersView(Myorder _myorder) {
    bool _orderHasFiles = false;
    if (_myorder.materials.length > 0) {
      _orderHasFiles = true;
      print(_myorder.materials);

      ScopedModel.of<UserModel>(context, rebuildOnChange: true)
          .addOrderMaterials(_myorder.materials);
    }

    return AwesomeDialog(
      useRootNavigator: true,
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order #",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.id.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text("Details",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Text("============================"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Subject:",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.black),
                ),
                SizedBox(width: 10),
                Text(_myorder.subject),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Pages/Words:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.pages),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Delivery Time :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.urgency),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Total Cost :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.total),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Writing Style:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Document Type:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.document),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Academic Level:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.academiclevel),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Language :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.langstyle),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Line Spacing :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.spacing),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order Status:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.status),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Payment Status:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.payment),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Date Ordered:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.created_at),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Last Update:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.created_at),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Topic:",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.black)),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _myorder.topic,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Instructions:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _myorder.description,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Reference materials:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            _orderHasFiles
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: 'View Attached files',
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                showModalBottomSheet(
                                    isDismissible: true,
                                    useRootNavigator: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ViewOrderFilesBottomSheet(
                                        myorder: _myorder,
                                        token: _token,
                                      );
                                    });
                              },
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                      ),
                      SizedBox(height: 50),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Reference materials attached",
                      ),
                    ],
                  ),
            SizedBox(width: 10),
            SizedBox(height: 10),
            Container(
              height: 38,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                child: Material(
                    color: Theme.of(context).primaryColor,
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(context);
                        ScopedModel.of<OrderModel>(context,
                                rebuildOnChange: true)
                            .setTotalCost(double.parse(_myorder.total));

                        Navigator.pushNamed(context, RouteNames.uploadMaterial,
                            arguments: FinalOrderDetails(
                              int.parse(_myorder.id.toString()),
                              _myorder.subject,
                              _myorder.document,
                              _myorder.pages,
                              _myorder.urgency,
                            ));
                      },
                      minWidth: MediaQuery.of(context).size.width,
                      child: Text('Attach files'),
                    )),
              ),
            )
          ],
        )),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {},
    )..show();
  }

//End view for progress...in revision and completed orders

  pendingOrdersView(Myorder _myorder) {
    bool _orderHasFiles = false;
    if (_myorder.materials.length > 0) {
      _orderHasFiles = true;

      ScopedModel.of<UserModel>(context, rebuildOnChange: true)
          .addOrderMaterials(_myorder.materials);
    }

    return AwesomeDialog(
      useRootNavigator: true,
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order #",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.id.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text("Details",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Text("============================"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Subject:",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.black),
                ),
                SizedBox(width: 10),
                Text(_myorder.subject),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Pages/Words:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.pages),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Delivery Time :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.urgency),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Total Cost :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.total),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Writing Style:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.style),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Document Type:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.document),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Academic Level:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.academiclevel),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Language :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.langstyle),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Line Spacing :",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.spacing),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order Status:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.status),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Payment Status:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.payment),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Date Ordered:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.created_at),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Last Update:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(_myorder.created_at),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Topic:",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.black)),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _myorder.topic,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Instructions:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _myorder.description,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Reference materials:",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            _orderHasFiles
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: 'View Attached files',
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                showModalBottomSheet(
                                    isDismissible: true,
                                    useRootNavigator: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ViewOrderFilesBottomSheet(
                                        myorder: _myorder,
                                        token: _token,
                                      );
                                    });
                              },
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                      ),
                      SizedBox(height: 50),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Reference materials attached",
                      ),
                    ],
                  ),
            SizedBox(width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                FlatButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.editorder,
                          arguments: EditOrderDetails(
                              _myorder.id.toString(),
                              _myorder.description,
                              _myorder.langstyle,
                              _myorder.topic,
                              _myorder.style));
                    },
                    color: Colors.grey[300],
                    icon: Icon(
                      MyFlutterApp.edit,
                      color: Colors.blue,
                    ),
                    label: Text('Edit')),
                SizedBox(width: 10),
                FlatButton.icon(
                    icon: Icon(
                      MyFlutterApp.trash_empty,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showUserStatusDialog(_myorder);
                    },
                    color: Colors.grey[300],
                    label: Text('Delete')),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 38,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                child: Material(
                    color: Theme.of(context).primaryColor,
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    child: RaisedButton.icon(
                      icon: Icon(
                        MyFlutterApp.attach,
                        color: Colors.blue,
                      ),

                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(context);
                        ScopedModel.of<OrderModel>(context,
                                rebuildOnChange: true)
                            .setTotalCost(double.parse(_myorder.total));

                        Navigator.pushNamed(context, RouteNames.uploadMaterial,
                            arguments: FinalOrderDetails(
                              _myorder.id,
                              _myorder.subject,
                              _myorder.document,
                              _myorder.pages,
                              _myorder.urgency,
                            ));
                      },
                      // minWidth: MediaQuery.of(context).size.width,
                      label: Text('Attach files'),
                    )),
              ),
            )
          ],
        )),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {},
    )..show();
  }

  Widget pendingOrders() {
    // var _orders = _pendingOrders['data'];

    return _isTablet
        ?
        //Display for tablet
        ListView(children: [
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Awaiting Payment',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Document Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost(USD)',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.money,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(double.parse(order.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.makepayments,
                                      arguments: FinalOrderDetails(
                                        int.parse(order.id.toString()),
                                        order.subject,
                                        order.document,
                                        order.pages,
                                        order.urgency,
                                      ));
                                },
                                label: Text('Pay'),
                              )),
                              DataCell(FlatButton.icon(
                                    color: Colors.grey[300],
                                  onPressed: () {
                                    _myorder = order;

                                    pendingOrdersView(_myorder);
                                  },
                                  icon: Icon(MyFlutterApp.eye,
                                      color: Colors.grey),
                                  label: Text('View')))
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
            SizedBox(height: 20),
            Center(
                child: Text(
              'Awaiting writer allocation',
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
            )),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Document Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost(USD)',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _waiting
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;
                                  pendingOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _myorder = order;

                                  Navigator.pushNamed(
                                      context, RouteNames.editorder,
                                      arguments: EditOrderDetails(
                                          _myorder.id.toString(),
                                          _myorder.description,
                                          _myorder.langstyle,
                                          _myorder.topic,
                                          _myorder.style));
                                },
                                label: Text('Edit'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            )
          ])
        //Display for not tablet
        : ListView(children: [
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Awaiting Payment',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost(USD)',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.money,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(double.parse(order.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.makepayments,
                                      arguments: FinalOrderDetails(
                                        order.id,
                                        order.subject,
                                        order.document,
                                        order.pages,
                                        order.urgency,
                                      ));
                                },
                                label: Text('Pay'),
                              )),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  pendingOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
            SizedBox(height: 20),
            Center(
                child: Text(
              'Awaiting writer allocation',
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
            )),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost(USD)',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _waiting
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;
                                  pendingOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _myorder = order;

                                  Navigator.pushNamed(
                                      context, RouteNames.editorder,
                                      arguments: EditOrderDetails(
                                          _myorder.id.toString(),
                                          _myorder.description,
                                          _myorder.langstyle,
                                          _myorder.topic,
                                          _myorder.style));
                                },
                                label: Text('Edit'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            )
          ]);
  }

  Widget progressOrders() {
    return _isTablet
        ?
        //Display for tablet
        ListView(children: [
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Assigned to writers',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Document Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _progress
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  progressRevisionOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.attach,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(
                                          double.parse(_myorder.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.uploadMaterial,
                                      arguments: FinalOrderDetails(
                                        int.parse(_myorder.id.toString()),
                                        _myorder.subject,
                                        _myorder.document,
                                        _myorder.pages,
                                        _myorder.urgency,
                                      ));
                                },
                                label: Text('Add files'),
                              ))
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
          ])
        //Display for not tablet
        : ListView(children: [
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Assigned to writers',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _progress
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  progressRevisionOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.attach,
                                  color: Colors.blue,
                                  // size: 12.0,
                                ),
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(
                                          double.parse(_myorder.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.uploadMaterial,
                                      arguments: FinalOrderDetails(
                                        int.parse(_myorder.id.toString()),
                                        _myorder.subject,
                                        _myorder.document,
                                        _myorder.pages,
                                        _myorder.urgency,
                                      ));
                                },
                                label: Text('Attach'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
          ]);
  }

  Widget revisionOrders() {
    return _isTablet
        ?
        //Display for tablet
        ListView(children: [
            _isSending ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Under Revision',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Document Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _revision
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.download,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSending = true;
                                  });
                                  _downLoadCompletedPaper(order.id.toString());
                                },
                                label: Text('Download'),
                              )),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;
                                  progressRevisionOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
          ])
        //Display for not tablet
        : ListView(children: [
            _isSending ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Under Revision',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _revision
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  progressRevisionOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.download,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSending = true;
                                  });

                                  _downLoadCompletedPaper(order.id.toString());
                                },
                                label: Text('Download'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
          ]);
  }

  Widget completedOrders() {
    return _isTablet
        ?
        //Display for tablet
        ListView(children: [
            _isSending ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Completed ',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Pages/slides',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Document Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _completed
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  completedOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.download,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
//Download the paper button

                                  setState(() {
                                    _isSending = true;
                                  });
                                  _downLoadCompletedPaper(order.id.toString());
                                },
                                label: Text('Download'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.cw,
                                  color: Colors.grey,
                                ),
                                onPressed: () {},
                                label: Text('Revise'),
                              ))
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
          ])
        //Display for not tablet
        : ListView(children: [
            _isSending ? LinearProgressIndicator() : SizedBox(height: 20),
            Center(
              child: Text(
                'Completed',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 6.0,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Cost',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ],
                    rows: _completed
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id.toString())),
                              DataCell(Text(order.total)),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.download,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSending = true;
                                  });
                                  _downLoadCompletedPaper(order.id.toString());
                                },
                                label: Text('Download'),
                              )),
                              DataCell(RaisedButton.icon(
                                icon: Icon(
                                  MyFlutterApp.cw,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
//Download the paper button
                                },
                                label: Text('Revise'),
                              )),
                              DataCell(FlatButton.icon(
                                icon: Icon(
                                  MyFlutterApp.eye,
                                  color: Colors.grey,
                                ),
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  completedOrdersView(_myorder);
                                },
                                label: Text('View'),
                              )),
                            ]))
                        .toList(),
                  ),
                ))
              ],
            ),
          ]);
  }
}

class ViewOrderFilesBottomSheet extends StatefulWidget {
  const ViewOrderFilesBottomSheet(
      {@required this.myorder, @required this.token, Key key})
      : super(key: key);
  final Myorder myorder;

  final String token;

  _ViewOrderFilesBottomSheetState createState() =>
      _ViewOrderFilesBottomSheetState();
}

class _ViewOrderFilesBottomSheetState extends State<ViewOrderFilesBottomSheet> {
  final GlobalKey<ScaffoldState> _updateScaffold = new GlobalKey();
  bool _isDeletingorderfiles = false;
  bool _isTablet = false;

  _showMsg(String msg, Color color) {
    final snackbar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _updateScaffold.currentState.showSnackBar(snackbar);
  }

//Delete order files
  void deleteOrderFiles(var index, int id) async {
    setState(() {
      _isDeletingorderfiles = true;
    });

    String _apiUrl =
        "/order/" + widget.myorder.id.toString() + "/images/" + id.toString();

    try {
      var _response = await Network().deleteData(_apiUrl, widget.token);

      if (_response.statusCode == 200) {
        setState(() {
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .loadUserOrders();

          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .removeOrderMaterial(index);

          _isDeletingorderfiles = false;
        });
        _showMsg('File deleted successfully.', Colors.green);
      } else if (_response.statusCode == 404) {
        _showMsg('File not found.Error code 404', Colors.red);

        setState(() {
          _isDeletingorderfiles = false;
        });
      } else {
        setState(() {
          _isDeletingorderfiles = false;
        });

        _showMsg(
            "Failed to delete the order material.Try again please:Error code" +
                _response.statusCode.toString(),
            Colors.red);
      }
    } catch (e) {
      print(e);

      setState(() {
        _isDeletingorderfiles = false;
      });
      _showMsg(
          "Failed to delete the order material...Try again please", Colors.red);
    }
  }

//End deleting order files
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    setState(() {
      if (_width >= 600) {
        _isTablet = true;
      }
    });

    return Scaffold(
      backgroundColor: speedySurfacebackground,
      key: _updateScaffold,
      body: _isTablet
          ? Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: ListView(
                children: [
                  // SizedBox(height: 30),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text("Order #",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black)),
                  //     SizedBox(width: 10),
                  //     Text(widget.myorder.id.toString(),
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black)),
                  //     SizedBox(width: 10),
                  //     Text("materials",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black)),
                  //   ],
                  // ),
                  // Center(
                  //   child: Text("======================="),
                  // ),
                  _isDeletingorderfiles
                      ? LinearProgressIndicator()
                      : SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                        child: DataTable(
                      columnSpacing: 6.0,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                            label: Text(
                          'File#',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: Colors.black),
                        )),
                        DataColumn(
                            label: Center(
                          child: Text(
                            'Filename',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black),
                          ),
                        )),
                        DataColumn(
                            label: Text(
                          'Action ',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: Colors.black),
                        )),
                      ],
                      // rows: widget.myorder.materials
                      rows: ScopedModel.of<UserModel>(context,
                              rebuildOnChange: true)
                          .ordermaterials
                          .map((_file) => DataRow(cells: [
                                DataCell(Text(_file.id.toString())),
                                DataCell(Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _file.original_filename,
                                        maxLines: 3,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                )),
                                 DataCell(
                                  IconButton(
                                    icon: Icon(
                                      MyFlutterApp.trash_empty,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      var _index = ScopedModel.of<UserModel>(
                                              context,
                                              rebuildOnChange: true)
                                          .ordermaterials
                                          .indexOf(_file);

                                      deleteOrderFiles(_index, _file.id);
                                    },
                                  ),

                                  // RichText(
                                  //   text: TextSpan(
                                  //       text: 'Delete',
                                  //       recognizer: new TapGestureRecognizer()
                                  //         ..onTap = () {
                                  //           // deleteOrderFiles(_file,
                                  //           //     _file.id.toString(), _file.filename);
                                  //         },
                                  //       style: TextStyle(
                                  //           fontWeight: FontWeight.w600,
                                  //           decoration: TextDecoration.underline,
                                  //           color: Colors.red)),
                                  // ),
                                ),
                              ]))
                          .toList(),
                    )),
                  )
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: ListView(
                children: [
                  // SizedBox(height: 30),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text("Order #",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black)),
                  //     SizedBox(width: 10),
                  //     Text(widget.myorder.id.toString(),
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black)),
                  //     SizedBox(width: 10),
                  //     Text("materials",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w800,
                  //             color: Colors.black)),
                  //   ],
                  // ),
                  // Text("======================="),
                  _isDeletingorderfiles
                      ? LinearProgressIndicator()
                      : SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Center(
                        child: DataTable(
                          showBottomBorder: true,
                      columnSpacing: 6.0,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                            label: Text(
                          'File#',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: Colors.black),
                        )),
                        DataColumn(
                            label: Center(
                          child: Text(
                            'Filename',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black),
                          ),
                        )),
                        DataColumn(
                            label: Text(
                          'Action ',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: Colors.black),
                        )),
                      ],
                      rows: ScopedModel.of<UserModel>(context,
                              rebuildOnChange: true)
                          .ordermaterials
                          .map((_file) => DataRow(cells: [
                         
                               
                                DataCell(Text(_file.id.toString())),
                                DataCell(
                                  Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _file.original_filename,
                                        maxLines: 3,
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                )
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      MyFlutterApp.trash_empty,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      var _index = ScopedModel.of<UserModel>(
                                              context,
                                              rebuildOnChange: true)
                                          .ordermaterials
                                          .indexOf(_file);

                                      deleteOrderFiles(_index, _file.id);
                                    },
                                  ),

                                  // RichText(
                                  //   text: TextSpan(
                                  //       text: 'Delete',
                                  //       recognizer: new TapGestureRecognizer()
                                  //         ..onTap = () {
                                  //           // deleteOrderFiles(_file,
                                  //           //     _file.id.toString(), _file.filename);
                                  //         },
                                  //       style: TextStyle(
                                  //           fontWeight: FontWeight.w600,
                                  //           decoration: TextDecoration.underline,
                                  //           color: Colors.red)),
                                  // ),
                                ),
                              ]))
                          .toList(),
                    )),
                  )
                ],
              ),
            ),
    );
  }
}
