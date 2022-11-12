import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pay/pay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';
import 'globals.dart';
import 'paytm_config.dart';

class Paywith extends StatefulWidget {
  final Book book;
  const Paywith({Key? key, required this.book}) : super(key: key);

  @override
  State<Paywith> createState() => _PaywithState(this.book);
}

class _PaywithState extends State<Paywith> {
  var _gpaypaymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '1',
      status: PaymentItemStatus.final_price,
    )
  ];

  final Book book;

  _PaywithState(this.book);
  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      price = book.price;
      discount = 0;
    });
    settotal();
  }

  var purchaseid;
  var userid;
  Future createpurchase() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');

    var url1 = Uri.parse(
        host + '/api/users?filters[username][\$eq]=$username&populate=*');
    http.Response response1 = await http.get(url1);

    var data = jsonDecode(response1.body);
    userid = data[0]['id'];

    var url = Uri.parse(host + '/api/purchases');

    http.Response response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'data': {
            'users_permissions_user': [userid],
            'status': 'Pending',
            'subtotal': book.price,
            'discount': 0,
            'tax': 0,
            'total': book.price,
            'book': [book.id]
          }
        }));
    var data2 = jsonDecode(response.body);
    return data2['data']['id'];
  }

  double discount = 0;
  void settotal() {
    setState(() {
      total = price! - tax - ((discount * price!) / 100);
    });
  }

  Future checkredeemcode(code) async {
    if (_formKey.currentState!.validate()) {
      var url = Uri.parse(host + '/api/coupons');
      http.Response response = await http.get(url);
      var data = jsonDecode(response.body);
      if (data['data'].isNotEmpty) {
        for (var element in data['data']) {
          if (element['attributes']['couponcode'] == code) {
            setState(() {
              validcode = true;
              discount = element['attributes']['discount'].toDouble();
              settotal();
            });
            break;
          }
        }
      }
    }
  }

  TextEditingController _codecontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool validcode = false;
  bool _isloading = false;
  double? price;
  double tax = 0;
  double? total;
  bool discountline = false;
  String? enteredcode;
  bool disableediting = false;
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isloading,
      progressIndicator: SpinKitThreeBounce(color: Color(0xFF0D47A1)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: [
                  Row(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 80, left: 10),
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            'Pay',
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                            ),
                          )),
                    )
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0, left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Redeem Coupon :',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                            key: _formKey,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 30,
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF0D47A1),
                                ),
                                readOnly: disableediting,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: _codecontroller,
                                onChanged: (value) {
                                  enteredcode = value;
                                },
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF0D47A1))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF0D47A1))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF0D47A1))),
                                  suffix: InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8,
                                          top: 4,
                                          bottom: 4),
                                      child: Text(
                                        validcode ? 'REMOVE' : 'APPLY',
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (validcode) {
                                        _codecontroller.text = '';
                                        setState(() {
                                          validcode = false;
                                          disableediting = false;
                                        });
                                      } else {
                                        await checkredeemcode(enteredcode);
                                        if (validcode) {
                                          setState(() {
                                            discountline = true;
                                            disableediting = true;
                                          });
                                        } else {
                                          return errorSnackBar(
                                              context, 'Invalid Coupon Code.');
                                        }
                                      }
                                    },
                                  ),
                                  hintText: 'Enter Coupon Code',
                                  fillColor: Color(0xFF0D47A1),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  if (validcode)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.lightGreenAccent,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.redeem_outlined,
                                    size: 18,
                                  ),
                                ),
                                Text(
                                  'Applied : ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text('Extra '),
                                Text(discount.toString() + '%',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                Text(' off with your purchase'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Details :',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 140,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, bottom: 0, left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF0D47A1),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  price!.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 10, left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF0D47A1),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '- ' + ((discount * price!) / 100).toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.grey))),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 10, left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF0D47A1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '\u{20B9} ' + total!.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF0D47A1),
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // GooglePayButton(
                        //   paymentConfigurationAsset: 'gpay.json',
                        //   paymentItems: _gpaypaymentItems,
                        //   style: GooglePayButtonStyle.white,
                        //   width: 150,
                        //   height: 60,
                        //   type: GooglePayButtonType.pay,
                        //   margin: const EdgeInsets.only(top: 0.0),
                        //   onPaymentResult: onGooglePayResult,
                        //   loadingIndicator: const Center(
                        //     child: CircularProgressIndicator(),
                        //   ),
                        // ),
                        SizedBox(
                          height: 60,
                          width: 150,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(3),
                                shadowColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.black),
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.white)),
                            onPressed: () async {
                              setState(() {
                                _isloading = true;
                              });
                              purchaseid = await createpurchase();
                              await PaytmConfigState().generateTxnToken(
                                  total!,
                                  purchaseid.toString(),
                                  userid.toString(),
                                  book.id);
                            },
                            child: Container(
                                height: 60,
                                width: 60,
                                child: SvgPicture.asset(
                                  'assets/paytm.svg',
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
