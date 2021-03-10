import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/network_utils/api.dart';

import 'package:speedywriter/serializablemodelclasses/image.dart';

import 'package:speedywriter/serializablemodelclasses/user.dart';
import 'package:speedywriter/serializablemodelclasses/referral.dart';
import 'package:speedywriter/serializablemodelclasses/earning.dart';

import 'manageorders/myorderseriazable.dart';

import 'dart:convert';

class UserModel extends Model {
  bool isUserLoggedIn = false;
  String token;
  String email;
  String userid;
  User user;
  bool userHasProfileImage = false;
  String avatarImageUrl;
  bool orderHasFiles = false;
  String publickey;
  String enckey;
  double rewards = 0.0;

  //Map pendingOrders;
  List<Myorder> pendingOrders = List<Myorder>();
  List<Myorder> assignedOrders = List<Myorder>();
  List<Myorder> revisionOrders = List<Myorder>();
  List<Myorder> completedOrders = List<Myorder>();
  List<Myorder> waitingOrders = List<Myorder>();
  List<Image> ordermaterials = List<Image>();
  List<Referral> referralList = List<Referral>();
  List<Earning> earningList = List<Earning>();

  void setTokenAndUserEmail(String _token, String _email, String _userid) {
    token = _token;
    email = _email;
    userid = _userid;

    notifyListeners();
  }

  void addUserDetails(Map userMap) {
    user = User.fromJson(userMap);

    notifyListeners();
  }

  void updateUserProfileImage(String avaterurl) {
    avatarImageUrl = avaterurl;

    notifyListeners();
  }

  void updatePhoneLoggedUser(String _phone, String _country) {
    user.phone_number = _phone;
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
  void addNewOrderToPendingOrders(Myorder _myorder) {
    pendingOrders.add(_myorder);
    notifyListeners();
  }

//Method to load card payments keys
  void loadCardPaymentKeys() async {
    if (isUserLoggedIn) {
      var _url = "/getcardkeys/1";
      try {
        var _response = await Network().getData(_url);

        if (_response.statusCode == 200) {
          var _jsonResponse = json.decode(_response.body);
          publickey = _jsonResponse['public_key'];
          enckey = _jsonResponse['enc_key'];

          notifyListeners();
        } else {
          enckey = null;
          publickey = null;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void loadUserReferrals() async {
    if (isUserLoggedIn) {
      var _url = "/user/" + userid + "/referrals";
      try {
        final _response = await Network().getUserData(_url, token);

        if (_response.statusCode == 200) {
          Map _data = json.decode(_response.body);

          _addReferralsToReferralList(_data);
          notifyListeners();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _addReferralsToReferralList(Map _referralsData) {
    referralList.clear();

    var _referrals = _referralsData['data'];

    for (var referral in _referrals) {
      Map myMap = referral;

      referralList.add(Referral.fromJson(myMap));
    }
    notifyListeners();
  }

  void loadUserEarnings() async {
    earningList.clear();
    if (isUserLoggedIn) {
      var _url = "/user/" + userid + "/earnings";
      try {
        final _response = await Network().getUserData(_url, token);

        if (_response.statusCode == 200) {
          Map _data = json.decode(_response.body);

          var _earnings = _data['data'];
          double paidin = 0;
          double paidout = 0;

          for (var earning in _earnings) {
            paidin = paidin + double.parse(earning['paid_in']);
            paidout = paidout + double.parse(earning['paid_out']);
            // print("paid in amount is============= " + paidin.toString());
            //             print("paid out amount is============= " + paidout.toString());

            earningList.add(Earning.fromJson(earning));
          }

          rewards = paidin - paidout;
       

          notifyListeners();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void addNewReferralToList(Referral _referral) {
    referralList.add(_referral);
    notifyListeners();
  }

  void loadUserOrders() async {
    if (isUserLoggedIn) {
      var _ordersUrl = "/user/" + userid + "/orders";
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

  void addOrderMaterials(List<Image> materials) {
    ordermaterials.clear();
    ordermaterials = materials;

    notifyListeners();
  }

//End user loading materials

//Remove material from scoped model
  void removeOrderMaterial(var index) {
    ordermaterials.removeAt(index);
    if (ordermaterials.isEmpty) {
      orderHasFiles = false;
    }

    notifyListeners();
  }
//End removing material
//  void addOrderMaterial(Image addfile) {
//     ordermaterials.remove(addfile);
//     notifyListeners();
//   }

}
