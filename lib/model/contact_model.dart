import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String? uid;
  Timestamp? addedOn;
  int? lastMessageTime;
  int? unReadFromUser;
  List<String>? searchParam;

  ContactModel({this.uid, this.addedOn, this.lastMessageTime, this.searchParam, this.unReadFromUser});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      uid: json['uid'],
      lastMessageTime: json['lastMessageTime'],
      unReadFromUser: json['unReadFromUser'],
      addedOn: json['addedOn'],
      searchParam: json['searchParam'] != null ? List<String>.from(json['searchParam']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.uid != null) data['uid'] = this.uid;
    if (this.addedOn != null) data['addedOn'] = this.addedOn;
    if (this.unReadFromUser != null) data['unReadFromUser'] = this.unReadFromUser;
    if (this.lastMessageTime != null) data['lastMessageTime'] = this.lastMessageTime;
    if (this.searchParam != null) data['searchParam'] = this.lastMessageTime;

    return data;
  }
}
