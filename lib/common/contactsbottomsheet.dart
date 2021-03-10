
import 'package:flutter/material.dart';


import 'package:speedywriter/presentation/custom_icons.dart';

import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsBottomSheetState extends StatefulWidget {
  _ContactsBottomSheetState createState() => _ContactsBottomSheetState();
}

class _ContactsBottomSheetState extends State<ContactsBottomSheetState> {
  final GlobalKey<ScaffoldState> _addContactsScaffold =
      GlobalKey<ScaffoldState>();

void initState() {
    setState(() {
      super.initState();
    });
  }

  void dispose() {
 

    super.dispose();
  }

  String _platformVersion = 'Unknown';

//Open email
final Uri _emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'support@lastminutessay.us',
  queryParameters: {
    'subject': 'Hello Admin!'
  }
);


//Open call method
  _makingPhoneCall() async {
    const url = 'tel:+13414449713';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

//Opem whatsapp

  void whatsAppOpen() async {
    print("version is" + _platformVersion);

    FlutterOpenWhatsapp.sendSingleMessage("13414449713", "Hello");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterOpenWhatsapp.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

  @override
  Widget build(BuildContext context) {



    return Scaffold(
       key: _addContactsScaffold,

          body: Container(
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        child: ListView(children: [
          Card(
            elevation: 10,
            child: ListTile(
              leading: Icon(Icons.close),
              title: Text("Contact Us",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),

              onTap: () {
                Navigator.pop(context);
              },
              // selected: _selectedRoute == RouteNames.home,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.phone_in_talk),
            title: Text("Call Us"),
            subtitle: Text('+1(341) 444-9713'),
            onTap: _makingPhoneCall,

            // selected: _selectedRoute == RouteNames.home,
          ),
          Divider(),
          ListTile(
            leading: Icon(
              MyFlutterApp.whatsapp_1,
              color: Colors.green,
              // size: 80,
            ),
            title: Text('WhatsApp'),
            subtitle: Text('+1(341) 444-9713'),
            onTap: () {
              whatsAppOpen();
            },
            // selected: _selectedRoute == RouteNames.home,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email Us"),
            subtitle: Text('support@lastminutessay.us'),
            onTap: () async {
              launch(_emailLaunchUri.toString());
            },

            // selected: _selectedRoute == RouteNames.home,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text("Live Chat"),
            subtitle: Text(
              'Chat Online Now',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/chatadmin');
            },
          ),
          Divider(),
        ]),
      ) 
      );
    }
  }

