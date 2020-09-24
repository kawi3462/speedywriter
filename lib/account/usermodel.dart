import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:speedywriter/serializablemodelclasses/ordermaterial.dart';

import 'package:speedywriter/serializablemodelclasses/user.dart';

import 'manageorders/myorderseriazable.dart';

import 'dart:convert';

class UserModel extends Model {
  bool isUserLoggedIn = false;
  String token;
  String email;
  User user;
  bool userHasProfileImage = false;
  String avatarImageUrl;
    bool orderHasFiles = false;
    String publickey;
    String enckey;

  //Map pendingOrders;
  List<Myorder> pendingOrders = List<Myorder>();
  List<Myorder> assignedOrders = List<Myorder>();
  List<Myorder> revisionOrders = List<Myorder>();
  List<Myorder> completedOrders = List<Myorder>();
  List<Myorder> waitingOrders = List<Myorder>();
  List<Ordermaterial> ordermaterials = List<Ordermaterial>();

  void setTokenAndUserEmail(String _token, String _email) {
    token = _token;
    email = _email;

    notifyListeners();
  }

  void addUserDetails(Map userMap) {
    user = User.fromJson(userMap);

    notifyListeners();
  }

  void updateUserProfileImage(String avaterurl) {
    user.avatar_url = avaterurl;
    avatarImageUrl = 'https://lastminutessay.us/storage/$avaterurl';

    notifyListeners();
  }

  void updatePhoneLoggedUser(String _phone, String _country) {
    user.phone = _phone;
    user.country = _country;
    notifyListeners();
  }

  void setUserProfileImageStatus(bool status) {
    userHasProfileImage = status;
    notifyListeners();
  }

  void setUserStatus(bool status) {
    isUserLoggedIn = status;
    notifyListeners();
  }

//Get user orders pending orders

  void _addPendingOrders(Map _pendingOrders) {
    pendingOrders.clear();
    waitingOrders.clear();
    assignedOrders.clear();
    revisionOrders.clear();
    completedOrders.clear();

    var _orders = _pendingOrders['data'];
    //returns a List of Maps

    for (var order in _orders) {
      //iterate over the list
      Map myMap = order; //store each map

      if (myMap['status'] == "Pending payment") {
        pendingOrders.add(Myorder.fromJson(myMap));
        notifyListeners();
      } else if (myMap['status'] == "Waiting Approval") {
        waitingOrders.add(Myorder.fromJson(myMap));
        notifyListeners();
      } else if (myMap['status'] == "Assigned to writers") {
        assignedOrders.add(Myorder.fromJson(myMap));
        notifyListeners();
      } else if (myMap['status'] == "Under Revision") {
        revisionOrders.add(Myorder.fromJson(myMap));
        notifyListeners();
      } else if (myMap['status'] == "Completed") {
        completedOrders.add(Myorder.fromJson(myMap));
        notifyListeners();
      }

      // print(myMap['id']);
      // print(myMap['pages']);
    }

    notifyListeners();
  }

//End pending orders

//Add a new order after submiting it
void addNewOrderToPendingOrders(Myorder _myorder ){
pendingOrders.add(_myorder);
notifyListeners();


}



//Method to load card payments keys
void loadCardPaymentKeys() async
{
if(isUserLoggedIn)
{


var _url = "/getcardkeys/1";
      try {
        var _response = await Network().getData(_url);

        if (_response.statusCode == 200) {
 var _jsonResponse = json.decode(_response.body);
           publickey=_jsonResponse['public_key'];
enckey=_jsonResponse['enc_key'];

        
           
              notifyListeners();
      
        }
        else{
         enckey=null;
           publickey=null;

        }
      } 
      catch (e) {
        print(e);
      }


}


}





//End method to load card payment keys
  //Method to load user orders

  void loadUserOrders() async {
    if (isUserLoggedIn) {
      var _ordersUrl = "/myorders/" + email;
      try {
        final _response = await Network().getUserData(_ordersUrl, token);

        if (_response.statusCode == 200) {
          Map _data = json.decode(_response.body);
              notifyListeners();

          _addPendingOrders(_data);

          //  var _orders = _data['data'];
          //returns a List of Maps
          //  for (var order in _orders) {
          //iterate over the list
          //   Map myMap = order; //store each map
          //   print(myMap['id']);
          //   print(myMap['pages']);
          //}
      
        }
      } catch (e) {
        print(e);
      }
    }
  }

  //Load user order materials
  void loadUserOrderMaterials() async {
    if (isUserLoggedIn) {
      var _apiUrl = "/viewuserordermaterials/" + email;

      try {
        var _response = await Network().getUserData(_apiUrl, token);

        if (_response.statusCode == 200) {
          Map _orderfiles = json.decode(_response.body);

          _addUserOrderMaterials(_orderfiles);

          notifyListeners();
        } else if (_response.statusCode == 404) {}
      } catch (e) {
        print(e);
      }
    }
  }

  //End user materials loading

//
  void _addUserOrderMaterials(Map _orderfiles) {
    ordermaterials.clear();
    var _files = _orderfiles['data'];

    for (var file in _files) {
      //iterate over the list
      Map myFile = file;
      ordermaterials.add(Ordermaterial.fromJson(myFile));
    }

    notifyListeners();
  }

//End user loading materials

//Remove material from scoped model
  void removeOrderMaterial(Ordermaterial fileremoval) {
    ordermaterials.remove(fileremoval);
    notifyListeners();
  }
//End removing material
 void addOrderMaterial(Ordermaterial addfile) {
    ordermaterials.remove(addfile);
    notifyListeners();
  }

}

/*
  void checkIfUserLoggedIn() async {
    email = await Network().getEmail();
    token = await Network().getToken();

    if (email!=null) {
    

      var apiUrl = '/user';

      var response = await Network().getUserData(apiUrl, token);
      var jsonResponse = null;
      if (response.statusCode == 200) {
        Map userMap = jsonDecode(response.body);
        user = User.fromJson(userMap);
       isUserLoggedIn = true;
      } 
      
      else {
        isUserLoggedIn = false;
      }
    } else {
      isUserLoggedIn = false;
    }
    notifyListeners();
  }
*/
