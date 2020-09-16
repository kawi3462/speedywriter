import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';
import 'package:speedywriter/network_utils/api.dart';

import '../approuteobserver.dart';
import 'colors.dart';
import 'package:speedywriter/presentation/custom_icons.dart';
import 'package:speedywriter/serializablemodelclasses/user.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SimpleDrawer extends StatefulWidget {
  final bool permanentlyDisplay;

  const SimpleDrawer({@required this.permanentlyDisplay, Key key})
      : super(key: key);

  _SimpleDrawerState createState() => _SimpleDrawerState();
}

class _SimpleDrawerState extends State<SimpleDrawer> with RouteAware {
  bool _isUserLoggedIn = false;
  User _user;
  bool _hasprofileimage = false;
  String _imageUrl;

  String _selectedRoute;
  AppRouteObserver _routeObserver;
  @override
  void initState() {
    super.initState();
    _routeObserver = AppRouteObserver();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _updateSelectedRoute();
  }

  @override
  void didPop() {
    _updateSelectedRoute();
  }

  @override
  Widget build(BuildContext context) {
    _isUserLoggedIn = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
        .isUserLoggedIn;

    if (_isUserLoggedIn) {
      _user = ScopedModel.of<UserModel>(context, rebuildOnChange: true).user;
      
      _hasprofileimage =
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .userHasProfileImage;

      setState(() {
        _imageUrl = ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .avatarImageUrl;
      });
    }

    return new Drawer(
        child: Row(
      children: [
        Expanded(
          child: _isUserLoggedIn
              ? ListView(children: [
                  DrawerHeader(
                      decoration: BoxDecoration(color: speedyPurple100),
                      child: Center(
                        child: Container(
                          child: Row(children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, RouteNames.profile);
                                },
                                child: CircleAvatar(
                                    backgroundColor: Color(0xFFE6F0FA),
                                    radius: 55,
                                    child: ClipOval(
                                      child: _hasprofileimage
                                          ? Image.network(
                                              _imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : CircleAvatar(
                                              radius: 60,
                                              child: Image.asset(
                                                  'assets/icons/account.png'),
                                            ),
                                    ))),
                            Expanded(
                                flex: 2,
                                child: ListTile(
                                    title: _isUserLoggedIn
                                        ? Text(_user.name)
                                        : Text('Hello Guest'),
                                    subtitle:
                                        Text('Welcome at Lastminutessay.us')))
                          ]),
                        ),
                      )),
                  //Menu for user who is logged in

                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () async {
                  
                      _navigateTo(context, RouteNames.home);
                    },
                    selected: _selectedRoute == RouteNames.home,
                  ),
                  ListTile(
                      leading: Icon(Icons.add),
                      title: Text('New Order'),
                      onTap: () async {
                        _navigateTo(context, RouteNames.ordernow);
                      },
                      selected: _selectedRoute == RouteNames.ordernow),
                  ListTile(
                    leading: Icon(Icons.assignment),
                    title: Text('My Orders'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.myorders);
                    },
                    selected: _selectedRoute == RouteNames.myorders,
                  ),

                  ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Get a Quote'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.getquote);
                    },
                    selected: _selectedRoute == RouteNames.getquote,
                  ),
                  ListTile(
                      leading: Icon(Icons.person_add),
                      title: Text('Refer a friend'),
                      onTap: () {}),
                  ListTile(
                      leading: Icon(Icons.chat),
                      title: Text('Chat Admin'),
                      onTap: () {}),
                  ListTile(
                      leading: Icon(MyFlutterApp.list_numbered),
                      title: Text('Policies'),
                      onTap: () {}),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.account_box),
                    title: Text('My Account'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.profile);
                    },
                    selected: _selectedRoute == RouteNames.profile,
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Change Password'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.updatePassword);
                    },
                    selected: _selectedRoute == RouteNames.updatePassword,
                  ),

                  ListTile(
                    leading: Icon(MyFlutterApp.logout),
                    title: Text('Log Out'),
                    onTap: () async {

                      ScopedModel.of<UserModel>(context, rebuildOnChange: true) .setUserStatus(false);

                      
                      await Network().logOut();
Navigator.of(context)


    .pushNamedAndRemoveUntil(RouteNames.login, (Route<dynamic> route) => false);

                  

                     // _navigateTo(context, RouteNames.login);

                    },
                    selected: _selectedRoute == RouteNames.login,
                  ),
                ])
              //End user logged in and start user not logged in
              : ListView(children: [
                  DrawerHeader(
                      decoration: BoxDecoration(color: speedyPurple100),
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.login);
                          },
                          child: Container(
                            child: Row(children: [
                              CircleAvatar(
                                radius: 60,
                                child: Image.asset('assets/icons/account.png'),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: ListTile(
                                      title: Text('Tap To Login'),
                                      subtitle:
                                          Text('Welcome at Lastminutessay.us')))
                            ]),
                          ),
                        ),
                      )),
                  //Menu for user not logged in

                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.home);
                    },
                    selected: _selectedRoute == RouteNames.home,
                  ),

                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('New Order'),
                    onTap: () {
                      _showDialog();
                    },
                    selected: _selectedRoute == RouteNames.login,
                  ),

                  ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Get a Quote'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.getquote);
                    },
                    selected: _selectedRoute == RouteNames.getquote,
                  ),

                  ListTile(
                      leading: Icon(Icons.person_add),
                      title: Text('Refer a friend'),
                      onTap: () {}),

                  ListTile(
                      leading: Icon(Icons.chat),
                      title: Text('Chat Admin'),
                      onTap: () {}),

                  ListTile(
                      leading: Icon(MyFlutterApp.list_numbered),
                      title: Text('Policies'),
                      onTap: () {}),
                  Divider(),

                  ListTile(
                    leading: Icon(MyFlutterApp.login),
                    title: Text('Sign In'),
                    onTap: () async {
                      _navigateTo(context, RouteNames.login);
                    },
                    selected: _selectedRoute == RouteNames.login,
                  ),
                ]),

          //End user not logged in menu
        ),
        if (widget.permanentlyDisplay)
          const VerticalDivider(
            width: 1,
          )
      ],
    ));
  }

  Future<void> _showDialog() async {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: ' Would you like to login or sign up?',
      desc:
          'Before you can submit a new order you need to either login to your account or sign up ',
      btnCancelOnPress: () {
        Navigator.pop(context);
      },
      btnOkOnPress: () {
        _navigateTo(context, RouteNames.login);
      },
    )..show();
  }

  Future<void> _navigateTo(BuildContext context, String routeName) async {
    if (widget.permanentlyDisplay) {
      Navigator.pop(context);
    }
    await Navigator.pushNamed(context, routeName);
  }

  void _updateSelectedRoute() {
    setState(() {
      _selectedRoute = ModalRoute.of(context).settings.name;
    });
  }
}
