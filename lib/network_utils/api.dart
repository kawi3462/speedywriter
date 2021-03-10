import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Network {
  String token;
  String email;
  String id;


 //final String _url = "https://speedy-273302.uc.r.appspot.com/api/v1";
   // final String url = "https://speedy-273302.uc.r.appspot.com/api/v1";


 // final String _url = "http://10.0.2.2:8000/api/v1";
  //  final String url = "http://10.0.2.2:8000/api/v1";
 
 final String url="https://lastminutessay.us/api/v1";
 final String _url="https://lastminutessay.us/api/v1";

//Load user profile image if logged in with image

getUserAvatar(String userid,String imageId) async{

var headers=_setHeadersOrder(token);
var request = http.Request('GET', Uri.parse("https://lastminutessay.us/api/v1/user/"+userid+"/image/"+imageId));

//_url+"/user/"+userid+"/image/"+imageId

request.headers.addAll(headers);

http.StreamedResponse response = await request.send();

if (response.statusCode == 200) {
//return Image.memory(response.toBy);

//response.stream.bytesToString();
}
else {
return response.reasonPhrase;
}




}


//End loading image 

//=====================login method=====================
        loginData(data) async {
              var apiUrl = "/login";
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl, body: data, headers:_setSignupHeaders());
  }
//====================================================
//===============Sign up method=====================

  signUpData(data) async {
      var apiUrl = "/user";
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl, body: data, headers:_setSignupHeaders());
  }
//====================================================





 

  _getTokenEmail() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token') ?? '';
    email = localStorage.getString('email') ?? '';
  }

  authData(data) async {
           var apiUrl = "/login";
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl, body: data, headers: _setHeaders());
  }

//Get user data 

  getUserData( apiUrl, token) async {
    var fullUrl = _url + apiUrl;
    return await http.get(fullUrl,  headers: _setHeadersOrder(token));
  }

//end get userdata
//Delete data
deleteData(apiUrl,token) async
{
 var fullUrl = _url+apiUrl;
    return await http.delete(fullUrl, headers: _setHeadersOrder(token));

}
updateData(apiUrl, token)  async
{
 var fullUrl = _url+apiUrl;
    return await http.put(fullUrl, headers: _setHeadersOrder(token));

}

//End deleteting data

deleteOrderFiles(apiUrl,token) async
{
 var fullUrl = _url + apiUrl;
    return await http.post(fullUrl, headers: _setHeadersOrder(token));

}


//================================Special methods
  submitData(data, apiUrl, token) async {
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl, body: data, headers: _setHeadersOrder(token));
  }




 _setHeadersOrder(String token) => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

  
 resetPassword(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl, body: data, headers:_setSignupHeaders());
  }




//Sign up headers
  _setSignupHeaders() => {
      'Content-type': 'application/json',
       'Accept': 'application/json',
      };

//===============================


  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getTokenEmail();
    return await http.get(fullUrl, headers: _setHeaders());
  }

  _setHeaders() => {
       'Content-type': 'application/json',
        'Accept': 'application/json',
       'Authorization': 'Bearer $token'
      };





  logOut() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

await localStorage.remove('email');
await localStorage.remove('token');


  }

 
   getUserID() async{
      SharedPreferences localStorage = await SharedPreferences.getInstance();
       return localStorage.getString('userid');


 }



  getEmail() async{
      SharedPreferences localStorage = await SharedPreferences.getInstance();
       return localStorage.getString('email');


 }
 getToken() async {
   try{
  SharedPreferences localStorage = await SharedPreferences.getInstance();
       return localStorage.getString('token');
   }
catch(MissingPluginException ){
 print(e);

}


}
  

}
