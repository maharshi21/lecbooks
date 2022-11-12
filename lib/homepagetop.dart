import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lecbooks/globals.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

class Homepagetop extends StatefulWidget {
  const Homepagetop({Key? key}) : super(key: key);

  @override
  State<Homepagetop> createState() => _HomepagetopState();
}

class _HomepagetopState extends State<Homepagetop> {
  late List data;
  List imagesUrl = [];
  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }

  Future fetchDataFromApi() async {
    var url = Uri.parse(host + '/api/books?populate=coverpage');

    http.Response response = await http.get(url);
    var fetchData = jsonDecode(response.body);
    if (!this.mounted) return;

    setState(() {
      data = fetchData['data'];

      data.forEach((element) {
        if (element['attributes']['coverpage']['data'] != null)
          imagesUrl.add(element['attributes']['coverpage']['data'][0]
              ['attributes']['url']);
        _isloading = false;
      });
    });
  }

  bool _isloading = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      height: MediaQuery.of(context).size.height * 0.25,
      child: _isloading
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.white,
              enabled: true,
              child: CarouselSlider.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int itemIndex, _) =>
                    Container(
                  margin: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 180,
                ),

                //Slider Container properties
                options: CarouselOptions(
                  height: 180.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
              ),
            )
          : CarouselSlider.builder(
              itemCount: imagesUrl.length,
              itemBuilder: (BuildContext context, int itemIndex, _) =>
                  Container(
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: imagesUrl.length != 0
                    ? FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: host + imagesUrl[itemIndex],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.35,
                        fit: BoxFit.fitHeight,
                      )
                    : SizedBox(
                        child: const CircularProgressIndicator(),
                        height: 5,
                        width: 50,
                      ),
              ),

              //Slider Container properties
              options: CarouselOptions(
                height: 180.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
            ),
    );
  }
}
