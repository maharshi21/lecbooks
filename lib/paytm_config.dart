import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lecbooks/classes.dart';
import 'package:lecbooks/globals.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aftertransaction.dart';
import 'collection.dart';

class PaytmConfig extends StatefulWidget {
  const PaytmConfig({Key? key}) : super(key: key);

  @override
  State<PaytmConfig> createState() => PaytmConfigState();
}

class PaytmConfigState extends State<PaytmConfig> {
  final String _mid = "QXgDVB84819996124675";
  final String _mKey = "oNXZelYYIpPZrsjr";
  final String _website = "WEBSTAGING"; // or "WEBSTAGING" in Testing
  final GlobalKey<AfterTransState> aftertransKey = GlobalKey<AfterTransState>();
  final _url = 'http://192.168.1.9:3000' +
      '/generateTxnToken'; // Add your own backend URL

  String get mid => _mid;
  String get mKey => _mKey;
  String get website => _website;
  String get url => _url;
  Transaction trans = Transaction();
  String getMap(
      double amount, String callbackUrl, String orderId, String Userid) {
    return json.encode({
      "mid": mid,
      "key_secret": mKey,
      "website": website,
      "orderId": orderId,
      "amount": amount.toString(),
      "callbackUrl": callbackUrl,
      "custId": Userid, // Pass users Customer ID here
    });
  }

  Future assignbooktouser(userid, bookid) async {
    var url = Uri.parse(host + '/api/users/$userid?populate=*');
    http.Response getresponse = await http.get(url);
    var data = jsonDecode(getresponse.body);
    print(data);
    var id = bookid;
    List ids = [];
    if (data['books'].isNotEmpty) {
      var url = Uri.parse(host + '/api/users/$userid');
      for (var element in data['books']) {
        ids.add(element['id']);
      }
      ids.add(id);
      http.Response response = await http.put(url,
          headers: headers, body: jsonEncode({'books': ids}));
    } else {
      var url = Uri.parse(host + '/api/users/$userid');
      for (var element in data['books']) {
        ids.add(element['id']);
      }
      ids.add(id);
      http.Response response = await http.put(url,
          headers: headers, body: jsonEncode({'books': ids}));
    }
  }

  Future createtrans(status, purchaseid, userid) async {
    var url = Uri.parse(host + '/api/transactions');

    http.Response response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'data': {
            'users_permissions_user': [userid],
            'status': status,
            'paymentmode': 'Paytm',
            'purchase': [purchaseid]
          }
        }));

    var data2 = jsonDecode(response.body);
    trans.id = data2['data']['id'].toString();
  }

  Future assigntrans(purchaseid, userid, bookid) async {
    var purstatus = 'Failed';
    var url = Uri.parse(host + '/api/purchases/$purchaseid');
    if (trans.status == 'Approved') {
      purstatus = 'Done';
    }
    http.Response response = await http.put(url,
        headers: headers,
        body: jsonEncode({
          'data': {
            'transaction': [trans.id],
            'status': purstatus
          }
        }));
    if (trans.status == 'Approved') {
      await assignbooktouser(userid, bookid);
    }

    return navService.pushNamed('/aftertrans',
        args: {'status': trans.status, 'bookid': bookid});
  }

  Future<void> generateTxnToken(
      double amount, String orderId, String Userid, bookid) async {
    final callBackUrl =
        'https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId';
    final body = getMap(amount, callBackUrl, orderId, Userid);

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {'Content-type': "application/json"},
      );
      String txnToken = response.body;
      await initiateTransaction(
          orderId, amount, txnToken, callBackUrl, Userid, bookid);
    } catch (e) {
      print(e);
    }
  }

  Future<void> initiateTransaction(String orderId, double amount,
      String txnToken, String callBackUrl, String Userid, bookid) async {
    String result = '';
    trans.status = 'Pending';
    trans.purchaseid = orderId;
    try {
      var response = AllInOneSdk.startTransaction(
        mid,
        orderId,
        amount.toString(),
        txnToken,
        callBackUrl,
        true, // isStaging
        false, // restrictAppInvoke
      );
      response.then((value) {
        // Transaction successfull
        trans.status = 'Approved';

        createtrans(trans.status, trans.purchaseid, Userid)
            .then((_) => assigntrans(trans.purchaseid, Userid, bookid));
        print(value);
      }).catchError((onError) {
        trans.status = 'Cancelled';

        createtrans(trans.status, trans.purchaseid, Userid)
            .then((_) => assigntrans(trans.purchaseid, Userid, bookid));
        if (onError is PlatformException) {
          result = onError.message! + " \n  " + onError.details.toString();
          print(result);
        } else {
          result = onError.toString();
          print(result);
        }
      });
    } catch (err) {
      // Transaction failed
      trans.status = 'Failed';

      await createtrans(trans.status, trans.purchaseid, Userid)
          .then((_) => assigntrans(trans.purchaseid, Userid, bookid));
      result = err.toString();
      print('NOOOOOOOO');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
