import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speedywriter/account/manageorders/editorderdetails.dart';

import 'package:speedywriter/appscaffoldforTabs.dart';

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

import 'package:speedywriter/serializablemodelclasses/ordermaterial.dart';

class MyOrders extends StatefulWidget {
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
//Orders
  Myorder _myorder;
  List<Myorder> _pending;
  List<Myorder> _waiting;
  List<Myorder> _progress;
  List<Myorder> _revision;
  List<Myorder> _completed;
  bool _isDeleting = false;
  bool _isTablet = false;
  bool orderHasFiles;
  List<Ordermaterial> _ordermaterial;

  List<Ordermaterial> oneOrdermaterial = new List<Ordermaterial>();
  String _token;

  //Start adding bottom nav==========
  String _lastSelected = 'TAB: 0';

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      if (index == 0) {
        Navigator.pushNamed(context, '/getquote');
      }
    });
  }

  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

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
    double _width = MediaQuery.of(context).size.width;
    setState(() {
      if (_width > 1000) {
        _isTablet = true;
      }
    });
    ScopedModel.of<UserModel>(context, rebuildOnChange: true).loadUserOrders();
    orderHasFiles =
        ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles;

    _token = ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;
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
    _ordermaterial = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .ordermaterials;

    return AppScaffoldHomeTabs(
      tabBar: TabBar(
        tabs: [
          Tab(text: "Pending ", icon: Icon(Icons.warning)),
          Tab(text: "In Progress ", icon: Icon(Icons.autorenew)),
          Tab(text: "Revision ", icon: Icon(Icons.assignment_returned)),
          Tab(text: "Completed", icon: Icon(Icons.assignment_turned_in)),
        ],
      ),
      tabBarView: TabBarView(children: [
        pendingOrders(),
        progressOrders(),
        revisionOrders(),
        completedOrders(),
      ]),
      pageTitle: PageTitles.myorders,
    );
  }

//Delete order method
  void _deleteOrder(Myorder _myorder) async {
    setState(() {
      _isDeleting = true;
    });

    String _apiUrl = "/deleteorder/" + _myorder.id;

    try {
      var _response = await Network().deleteData(_apiUrl, _token);

      Navigator.pop(context);
      if (_response.statusCode == 200) {
        setState(() {
          _pending.remove(_myorder);
          _isDeleting = false;
        });
      } else if (_response.statusCode == 404) {
        // ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        //  .pendingOrders
        //  .remove(_myorder.id);
        setState(() {
          _pending.remove(_myorder);
          _isDeleting = false;
        });
      } else {
        print(_response.statusCode.toString());
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
    oneOrdermaterial.clear();
    _ordermaterial.forEach((_file) {
      if (_file.order_id == _myorder.id) {
        oneOrdermaterial.add(_file);
      }
    });

    if (oneOrdermaterial.length == 0) {
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles =
          false;
    } else {
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles =
          true;
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
                Text(_myorder.id,
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
                Text(_myorder.style),
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
                Text(_myorder.updated_at),
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
            ScopedModel.of<UserModel>(context, rebuildOnChange: true)
                    .orderHasFiles
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
                                          ordermaterial: oneOrdermaterial,
                                          token: _token,
                                          ordernumber: _myorder.id.toString());
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
    oneOrdermaterial.clear();
    _ordermaterial.forEach((_file) {
      if (_file.order_id == _myorder.id) {
        oneOrdermaterial.add(_file);
      }
    });

    if (oneOrdermaterial.length == 0) {
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles =
          false;
    } else {
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles =
          true;
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
                Text(_myorder.id,
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
                Text(_myorder.style),
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
                Text(_myorder.updated_at),
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
            ScopedModel.of<UserModel>(context, rebuildOnChange: true)
                    .orderHasFiles
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
                                          ordermaterial: oneOrdermaterial,
                                          token: _token,
                                          ordernumber: _myorder.id.toString());
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
                        ScopedModel.of<OrderModel>(context,
                                rebuildOnChange: true)
                            .setTotalCost(double.parse(_myorder.total));

                        Navigator.pushNamed(context, RouteNames.uploadMaterial,
                            arguments: FinalOrderDetails(
                              int.parse(_myorder.id),
                              _myorder.email,
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
    oneOrdermaterial.clear();
    _ordermaterial.forEach((_file) {
      if (_file.order_id == _myorder.id) {
        oneOrdermaterial.add(_file);
      }
    });

    if (oneOrdermaterial.length == 0) {
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles =
          false;
    } else {
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).orderHasFiles =
          true;
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
                Text(_myorder.id,
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
                Text(_myorder.style),
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
                Text(_myorder.updated_at),
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
            ScopedModel.of<UserModel>(context, rebuildOnChange: true)
                    .orderHasFiles
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
                                          ordermaterial: oneOrdermaterial,
                                          token: _token,
                                          ordernumber: _myorder.id.toString());
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
                FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.editorder,
                          arguments: EditOrderDetails(
                              _myorder.id,
                              _myorder.description,
                              _myorder.langstyle,
                              _myorder.topic,
                              _myorder.style));
                    },
                    color: Colors.grey[300],
                    child: Text('Edit')),
                SizedBox(width: 10),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        _isDeleting = true;
                      });
                      _deleteOrder(_myorder);
                    },
                    color: Colors.grey[300],
                    child: Text('Delete')),
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
                    child: MaterialButton(
                      onPressed: () {
                        ScopedModel.of<OrderModel>(context,
                                rebuildOnChange: true)
                            .setTotalCost(double.parse(_myorder.total));

                        Navigator.pushNamed(context, RouteNames.uploadMaterial,
                            arguments: FinalOrderDetails(
                              int.parse(_myorder.id),
                              _myorder.email,
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
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  pendingOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(double.parse(order.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        int.parse(order.id),
                                        order.email,
                                        order.subject,
                                        order.document,
                                        order.pages,
                                        order.urgency,
                                      ));
                                },
                                child: Text('Pay'),
                              ))
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
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  pendingOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {},
                                child: Text('Edit'),
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
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  pendingOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(double.parse(order.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        int.parse(order.id),
                                        order.email,
                                        order.subject,
                                        order.document,
                                        order.pages,
                                        order.urgency,
                                      ));
                                },
                                child: Text('Pay'),
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
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;
                                  pendingOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(
                                          double.parse(_myorder.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        int.parse(_myorder.id),
                                        _myorder.email,
                                        _myorder.subject,
                                        _myorder.document,
                                        _myorder.pages,
                                        _myorder.urgency,
                                      ));
                                },
                                child: Text('Edit'),
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
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  progressRevisionOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(
                                          double.parse(_myorder.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.uploadMaterial,
                                      arguments: FinalOrderDetails(
                                        int.parse(_myorder.id),
                                        _myorder.email,
                                        _myorder.subject,
                                        _myorder.document,
                                        _myorder.pages,
                                        _myorder.urgency,
                                      ));
                                },
                                child: Text('Add files'),
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
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  progressRevisionOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(
                                          double.parse(_myorder.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.uploadMaterial,
                                      arguments: FinalOrderDetails(
                                        int.parse(_myorder.id),
                                        _myorder.email,
                                        _myorder.subject,
                                        _myorder.document,
                                        _myorder.pages,
                                        _myorder.urgency,
                                      ));
                                },
                                child: Text('Add files'),
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
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
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
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(double.parse(order.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        int.parse(order.id),
                                        order.email,
                                        order.subject,
                                        order.document,
                                        order.pages,
                                        order.urgency,
                                      ));
                                },
                                child: Text('Download'),
                              )),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;
                                  progressRevisionOrdersView(_myorder);
                                },
                                child: Text('View'),
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
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
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
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  progressRevisionOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
                                  ScopedModel.of<OrderModel>(context,
                                          rebuildOnChange: true)
                                      .setTotalCost(double.parse(order.total));

                                  Navigator.pushNamed(
                                      context, RouteNames.paypal,
                                      arguments: FinalOrderDetails(
                                        int.parse(order.id),
                                        order.email,
                                        order.subject,
                                        order.document,
                                        order.pages,
                                        order.urgency,
                                      ));
                                },
                                child: Text('Download'),
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
            _isDeleting ? LinearProgressIndicator() : SizedBox(height: 20),
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
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id)),
                              DataCell(Text(order.pages)),
                              DataCell(Text(order.document)),
                              DataCell(Text(order.total)),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  completedOrdersView(_myorder);
                                },
                                child: Text('View'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
//Download the paper button
                                },
                                child: Text('Download'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {},
                                child: Text('Revise'),
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
                    rows: _pending
                        .map((order) => DataRow(cells: [
                              DataCell(Text(order.id)),
                              DataCell(Text(order.total)),
                              DataCell(RaisedButton(
                                onPressed: () {
//Download the paper button
                                },
                                child: Text('Download'),
                              )),
                              DataCell(RaisedButton(
                                onPressed: () {
//Download the paper button
                                },
                                child: Text('Revise'),
                              )),
                              DataCell(FlatButton(
                                color: Colors.grey[300],
                                onPressed: () {
                                  _myorder = order;

                                  completedOrdersView(_myorder);
                                },
                                child: Text('View'),
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
      {@required this.ordermaterial,
      @required this.token,
      @required this.ordernumber,
      Key key})
      : super(key: key);
  final List<Ordermaterial> ordermaterial;
  final String ordernumber;
  final String token;

  _ViewOrderFilesBottomSheetState createState() =>
      _ViewOrderFilesBottomSheetState();
}

class _ViewOrderFilesBottomSheetState extends State<ViewOrderFilesBottomSheet> {
  final GlobalKey<ScaffoldState> _updateScaffold = new GlobalKey();
  bool _isDeletingorderfiles = false;

  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
    _updateScaffold.currentState.showSnackBar(snackbar);
  }

//Delete order files
  void deleteOrderFiles(
      Ordermaterial material, String id, String filename) async {
    setState(() {
      _isDeletingorderfiles = true;
    });

    Map _data = {
      'file_name': filename,
    };

    String _datainput = jsonEncode(_data);

    String _apiUrl = "/deletematerials/" + id;

    try {
      var _response = await Network().deleteOrderFiles(
        _apiUrl,
        widget.token,
        _datainput,
      );

      if (_response.statusCode == 422) {
        setState(() {
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .removeOrderMaterial(material);

          widget.ordermaterial.remove(material);
          _isDeletingorderfiles = false;
        });
      } else if (_response.statusCode == 404) {
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .removeOrderMaterial(material);
        widget.ordermaterial.remove(material);

        if (widget.ordermaterial.length == 0) {
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .orderHasFiles = false;
        }

        print("response code is 404");
        setState(() {
          _isDeletingorderfiles = false;
        });
      } else {
        _showMsg('Error code' +
            _response.statusCode +
            "Failed to delete the order material");
      }
    } catch (e) {
      setState(() {
        _isDeletingorderfiles = false;
      });
      _showMsg("Failed to delete the order material...Try again please");
    }
  }

//End deleting order files
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: speedySurfacebackground,
      key: _updateScaffold,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        child: ListView(
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Order #",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text(widget.ordernumber,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
                SizedBox(width: 10),
                Text("materials",
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
            Center(
              child: Text("============================"),
            ),
            _isDeletingorderfiles
                ? LinearProgressIndicator()
                : SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
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
                          fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    'Action ',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black),
                  )),
                ],
                rows: widget.ordermaterial
                    .map((_file) => DataRow(cells: [
                          DataCell(Text(_file.id.toString())),
                          DataCell(Text(_file.original_filename)),
                          DataCell(
                            RichText(
                              text: TextSpan(
                                  text: 'Delete',
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      deleteOrderFiles(_file,
                                          _file.id.toString(), _file.filename);
                                    },
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      color: Colors.red)),
                            ),
                          ),
                        ]))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
