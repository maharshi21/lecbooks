import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/globals.dart';
import 'package:transparent_image/transparent_image.dart';
import 'classes.dart';
import 'aboutbookpage.dart';

class LoadingBookCard extends StatefulWidget {
  const LoadingBookCard({
    Key? key,
  }) : super(key: key);

  @override
  State<LoadingBookCard> createState() => _LoadingBookCardState();
}

class _LoadingBookCardState extends State<LoadingBookCard> {
  Widget bookcard() {
    return Card(
        elevation: 7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          height: 120,
          width: MediaQuery.of(context).size.width,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: bookcard(),
    );
  }
}
