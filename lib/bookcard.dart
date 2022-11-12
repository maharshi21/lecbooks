import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/globals.dart';
import 'package:transparent_image/transparent_image.dart';
import 'classes.dart';
import 'aboutbookpage.dart';

class BookCard extends StatefulWidget {
  const BookCard({
    Key? key,
    required this.book,
  }) : super(key: key);
  final book;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  Widget bookcard(Book book) {
    return Card(
        elevation: 7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AboutBookPage(
                          book: book,
                        )));
          },
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: host + book.coverpageurl!,
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width * 0.29,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    book.title!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            color: Color(0xFF0D47A1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20.0, left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      'By ' + book.authorname!,
                                      style: GoogleFonts.asap(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  Text('Subject: ' + book.subject!),
                                ],
                              ),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: book.ratings != null
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 20,
                                          color: Colors.amber,
                                        ),
                                        Text(book.ratings.toString(),
                                            style: GoogleFonts.asap())
                                      ],
                                    )
                                  : Container(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'sem' + book.sem! + '@' + book.institute!,
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            color: Colors.blueAccent)),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: bookcard(widget.book),
    );
  }
}
