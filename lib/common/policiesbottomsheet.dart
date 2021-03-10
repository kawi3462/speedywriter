
import 'package:flutter/material.dart';
import 'package:speedywriter/common/routenames.dart';


import 'package:speedywriter/presentation/custom_icons.dart';
import 'package:speedywriter/common/policiespagearguments.dart';

import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speedywriter/common/policiesbottomsheet.dart';

class PoliciesBottomSheetState extends StatefulWidget {
  _PoliciesBottomSheetState createState() => _PoliciesBottomSheetState();
}

class _PoliciesBottomSheetState extends State<PoliciesBottomSheetState> {
  final GlobalKey<ScaffoldState> _addPoliciesScaffold =
      GlobalKey<ScaffoldState>();

void initState() {
    setState(() {
      super.initState();
    });
  }

  void dispose() {
 

    super.dispose();
  }


 

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

  @override
  Widget build(BuildContext context) {



    return Scaffold(
       key: _addPoliciesScaffold,

          body: Container(
      
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        child: ListView(children: [
          Card(
            elevation: 10,
            child: ListTile(
              // leading: Icon(Icons.close),
              title: Text("Terms And Conditions",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),

              onTap: () {

String _title="Terms And Conditions";
String _url="https://lastminutessay.us/web/pay/terms.php";
          Navigator.pushNamed(
                                context, RouteNames.policy,
                                arguments: PolicyArguments(_title,_url));
              },
              // selected: _selectedRoute == RouteNames.home,
            ),
          ),
          // Divider(),
       SizedBox(height: 10,),
  Card(
            elevation: 10,
            child: ListTile(
              // leading: Icon(Icons.close),
              title: Text("Privacy Policy",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),

              onTap: () {
         String _title="Privacy Policy";
String _url="https://lastminutessay.us/web/pay/privacy.php";
          Navigator.pushNamed(
                                context, RouteNames.policy,
                                arguments: PolicyArguments(_title,_url));
              },
              // selected: _selectedRoute == RouteNames.home,
            ),
          ),

       SizedBox(height: 10,),

          Card(
            elevation: 10,
            child: ListTile(
              // leading: Icon(Icons.close),
              title: Text("Revision And Refund Policy",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),

              onTap: () {
              String _title="Revision And Refund Policy";
String _url="https://lastminutessay.us/web/pay/refund_revision_policy.php";
          Navigator.pushNamed(
                                context, RouteNames.policy,
                                arguments: PolicyArguments(_title,_url));
              },
              // selected: _selectedRoute == RouteNames.home,
            ),
          ),
                 SizedBox(height: 10,),
          Card(
            elevation: 10,
            child: ListTile(
              // leading: Icon(Icons.close),
              title: Text("Our Services",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),

              onTap: () {
             String _title="Our Services";
String _url="https://lastminutessay.us/web/pay/services.php";
          Navigator.pushNamed(
                                context, RouteNames.policy,
                                arguments: PolicyArguments(_title,_url));
              },
              // selected: _selectedRoute == RouteNames.home,
            ),
          ),
          SizedBox(height: 10,),
          
          Card(
            elevation: 10,
            child: ListTile(
              // leading: Icon(Icons.close),
              title: Text("Why Us ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),

              onTap: () {
             String _title="Why Us";
String _url="https://lastminutessay.us/web/pay/why_us.php";
          Navigator.pushNamed(
                                context, RouteNames.policy,
                                arguments: PolicyArguments(_title,_url));
              },
              // selected: _selectedRoute == RouteNames.home,
            ),
          ),

          // Divider(),
        
        ]),
      ) 
      );
    }
  }

