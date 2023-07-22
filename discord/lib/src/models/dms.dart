import 'dart:io';
import 'package:discord/src/models/hashing.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:discord/src/database/Databasemanipulate.dart';

class Dms {
  String? msender;
  String? mreciever;
  String? message;
  String? time;
  Dms(
      {required this.msender,
      required this.mreciever,
      required this.message,
      required this.time});
  Map<String, dynamic> toMap() {
    return {
      'message_sender': msender,
      'message_reciever': mreciever,
      'message': message,
      'time': time
    };
  }

  static Dms fromMap(Map<String, dynamic> map) {
    return Dms(
        msender: map['message_sender'],
        mreciever: map['message_reciever'],
        message: map['message'],
        time: map['time']);
  }

  sendmessage(String mr, String ms) async {
    var database = Databasemanipulation();
    mreciever = mr;
    msender = ms;
    var finder = Finder(filter: Filter.equals('username', mreciever));
    if (await database.finder(finder, 'users') == true) {
      print("Enter message");
      message = stdin.readLineSync();
      time = DateTime.now().toString();
      database.create(toMap(), 'dms');
      print("Message sent successfully");
    } else {
      print("Message reciever does not exist");
    }
  }

  seedms(String mr, String ms) async {
    var database = Databasemanipulation();
    mreciever = mr;
    msender = ms;
    var finder = Finder(filter: Filter.equals('username', msender));
    var filter = (Filter.equals('message_sender', msender) &
            Filter.equals('message_reciever', mreciever)) |
        (Filter.equals('message_sender', mreciever) &
            Filter.equals('message_reciever', msender));
    var finder2 = Finder(filter: filter);
    var finder3 = Finder(filter: Filter.equals('message_sender', msender));
    if (await database.finder(finder, 'users') == true) {
      List list = await database.getdata2(finder2, 'dms');
      if (list.isEmpty) {
        print("No messages have been shared");
      } else {
        for (var map in list) {
          print(map);
        }
      }
    } else {
      print("User does not exist");
    }
  }
}
