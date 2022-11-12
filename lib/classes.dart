class User {
  int? id;
  String? name;
  String? email;
  String? password;
  String? course;
  String? institute;
  String? sem;
  List<Book>? collection;

  User(
      {this.id,
      this.name,
      this.email,
      this.password,
      this.collection,
      this.course,
      this.institute,
      this.sem});
}

class Institute {
  final String? name;
  final String? fullname;
  Institute({this.name, this.fullname});
}

class Sem {
  final String? number;
  Sem({
    this.number,
  });
}

class Subject {
  final String? name;
  Subject({
    this.name,
  });
}

class Book {
  final int? id;
  final String? title;
  final String? subtitle;
  final String? authorname;
  final double? price;
  final String? date;
  final String? category;
  final String? institute;
  final String? subject;
  final String? coverpageurl;
  final String? sem;
  final double? ratings;
  final String? demopdfurl;
  final String? pdfurl;
  final String? publishdate;
  final String? course;
  Book(
      {this.id,
      this.title,
      this.subtitle,
      this.authorname,
      this.price,
      this.date,
      this.category,
      this.institute,
      this.subject,
      this.coverpageurl,
      this.sem,
      this.ratings,
      this.publishdate,
      this.demopdfurl,
      this.pdfurl,
      this.course});
}

class Transaction {
  String? userid;
  String? purchaseid;
  String? status;
  String? paymentmode;
  String? id;
}
