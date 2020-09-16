import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:speedywriter/appscaffold_home.dart';

import 'package:speedywriter/common/colors.dart';
import 'package:speedywriter/common/page_titles.dart';

import 'account/usermodel.dart';
import 'common/colors.dart';
import 'dart:convert';
import 'package:speedywriter/network_utils/api.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/services.dart';
import 'package:speedywriter/common/clippathcutcorners.dart';
import 'account/manageorders/myorderseriazable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:speedywriter/common/routenames.dart';

class FirstPage extends StatefulWidget {
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<Myorder> _pending;
  List<Myorder> _waiting;
  List<Myorder> _progress;
  List<Myorder> _revision;
  List<Myorder> _completed;
  bool _isUserLoggedIn = false;

  double _width;
  bool _isTablet;
  Image _image1;

  String _token;
  var connectivityResult;

  bool _userstatus = false;

  // String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void _checkUserStatus() async {
    _token = await Network().getToken();
if (_token!=null) {
      //Loading and updating user information
      String _email = await Network().getEmail();
      ScopedModel.of<UserModel>(context, rebuildOnChange: true)
          .setTokenAndUserEmail(_token, _email);

      setState(() {
        _userstatus = true;
      });
      var apiUrl = "/user";
      try {
        var _userdetailsresponse = await Network().getUserData(apiUrl, _token);

        Map _userMap = jsonDecode(_userdetailsresponse.body);
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .addUserDetails(_userMap);
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .setUserStatus(_userstatus);
        String _url = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .user
            .avatar_url;

        if (_url != "avatar.png") {
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .setUserProfileImageStatus(true);

          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .updateUserProfileImage(_url);
        }

        //end loading user information
        //Loading user orders ===============================

      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkUserStatus();
    //Load user orders if logged in

    //End loading user orders

    super.initState();
    _image1 = Image.asset(
      'assets/images/banner.jpg',
      gaplessPlayback: true,
    );
    _isTablet = false;

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_image1.image, context);
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _checkUserStatus();
      _showDialog();
    } else {
      _checkUserStatus();
    }
  }

  Future<void> _showDialog() async {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Check Internet Connection',
      desc:
          'This application need internet connection to work properly.Kindly check your internet connection !',
      btnCancelOnPress: () {},
      btnOkOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    //Check if user is logged in

    _isUserLoggedIn = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .isUserLoggedIn;

    //End checking user status

    //Load user orders
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
    //End loading user orders
      ScopedModel.of<UserModel>(context, rebuildOnChange: false).loadUserOrderMaterials();

    _width = MediaQuery.of(context).size.width;
    if (_width > 1000) {
      _isTablet = true;
    }

    return AppScaffoldHome(
        color: speedySurfacebackground,
        pageTitle: PageTitles.home,
        body: SafeArea(
            child: ListView(children: <Widget>[
          _buildHomeImage(),
          SizedBox(height: 12.0),
          _buildSecondMenu(),
          SizedBox(height: 20.0),
          _buildReferral(),
        ])));
  }

  Widget _buildReferral() {
    return Container(
      margin: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
          color: speedyPurple400,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          )),
      child: Center(
          child: InkWell(
              hoverColor: speedyPurple100,
              child: Ink(
                  child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 50,
                  ),
                  Column(
                    children: [
                      Text('Referral Rewards + Cashback'),
                      Text(
                        "USD: 10.0",
                        style: Theme.of(context).copyWith().textTheme.headline,
                      ),
                    ],
                  )
                ],
              )))),
    );
  }

  Widget _buildSecondMenu() {
    return Center(
      child: Container(
          // padding: _isTablet ? EdgeInsets.only(left: 50) : null,
          padding: EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: InkWell(
                        hoverColor: speedyPurple100,
                        child: Ink(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: speedyPurple50,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircleAvatar(
                                      child: Image.asset(
                                          'assets/icons/neworder.png'),
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text('New Order'),
                            ],
                          ),
                        ),
                        onTap: () {
                          _isUserLoggedIn
                              ? Navigator.pushNamed(context, '/home')
                              : _showUserStatusDialog('Login or Sign up first',
                                  'Before you can submit a new order you need to either login to your account or sign up');
                        })),
                Expanded(
                    flex: 2,
                    child: InkWell(
                      hoverColor: speedyPurple100,
                      onTap: () {
                        _isUserLoggedIn
                            ? Navigator.pushNamed(context, '/myorders')
                            : _showUserStatusDialog('Login or Sign up first',
                                'To  access your orders you need to either login to your account or sign up');
                      },
                      child: Ink(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: speedyPurple50,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircleAvatar(
                                    child: Image.asset(
                                        'assets/icons/myorders.png'),
                                  ),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Text('My Orders'),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: InkWell(
                    hoverColor: speedyPurple100,
                    child: Ink(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: speedyPurple50, shape: BoxShape.circle),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircleAvatar(
                                child: Image.asset('assets/icons/quote.png'),
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Get Quote'),
                      ],
                    )),
                    onTap: () {
                      Navigator.pushNamed(context, '/getquote');
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    hoverColor: speedyPurple100,
                    child: Ink(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: speedyPurple50,
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircleAvatar(
                                    child:
                                        Image.asset('assets/icons/friend.png')),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Refer a Friend'),
                        ],
                      ),
                    ),
                    onTap: () {
                      _isUserLoggedIn
                          ? Navigator.pushNamed(context, '/getquote')
                          : _showUserStatusDialog('Login or Sign up first',
                              'To  refer a friend  you need to either login to your account or sign up');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: InkWell(
                      hoverColor: speedyPurple100,
                      child: Ink(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: speedyPurple50,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircleAvatar(
                                      child:
                                          Image.asset('assets/icons/call.png')),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Call Admin'),
                          ],
                        ),
                      ),
                      onTap: () {},
                    )),
                Expanded(
                    flex: 2,
                    child: InkWell(
                      hoverColor: speedyPurple100,
                      child: Ink(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: speedyPurple50,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircleAvatar(
                                      child:
                                          Image.asset('assets/icons/chat.png')),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Chat Admin'),
                          ],
                        ),
                      ),
                      onTap: () {},
                    )),
              ],
            ),
          ])),
    );
  }
//Show dialog if user not logged in

  _showUserStatusDialog(String title, String desc) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: desc,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        Navigator.pushNamed(context, RouteNames.login);
      },
    )..show();
  }

//End dialog if user not logged in

  Widget _buildHomeImage() {
    return ClipPath(
      clipper: CustomClipPathHomeIMage(),
      child: Container(
          color: Colors.grey,
          child: Center(
            child: Stack(children: [
              _image1,
              Positioned(
                bottom: _isTablet ? -15 : -20.0,
                left: 20.0,
                right: 20.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  elevation: 5.0,
                  margin: EdgeInsets.fromLTRB(0, 12, 0, 12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                         
                          Column(
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Container(
                                  height: 50,
                                  width: 50,
                                  color: Color(0xFFE6FAF0),
                                  child: Center(
                                      child: _isUserLoggedIn
                                          ? Text(_pending.length.toString())
                                          : Text("0"))),
                              SizedBox(height: 10.0),
                              Text('Pending '),
                              Text('Orders'),
                              SizedBox(height: 30.0),
                            ],
                          ),    Column(
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Container(
                                  height: 50,
                                  width: 50,
                                  color: Color(0xFFFAE6F0),
                                  child: Center(
                                      child: _isUserLoggedIn
                                          ? Text(
                                                  _revision.length.toString()
                                                 )
                                             
                                          : Text("0"))),
                              SizedBox(height: 10.0),
                              Text('Revision '),
                              Text('Orders'),
                              SizedBox(height: 30.0),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Container(
                                  height: 50,
                                  width: 50,
                                  color: Color(0xFFFAF0E6),
                                  child: Center(
                                      child: _isUserLoggedIn
                                          ? Text((_progress.length +
                                                  _waiting.length)
                                              .toString())
                                          : Text('0'))),
                              SizedBox(height: 10.0),
                              Text('Live '),
                              Text('Orders'),
                              SizedBox(height: 30.0),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Container(
                                  height: 50,
                                  width: 50,
                                  color: Color(0xFFE6F0FA),
                                  child: Center(
                                      child: _isUserLoggedIn
                                          ? Text(_completed.length.toString())
                                          : Text('0'))),
                              SizedBox(height: 10.0),
                              Text('Completed '),
                              Text('Orders'),
                              SizedBox(height: 30.0),
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
            ]),
          )),
    );
  }
}
