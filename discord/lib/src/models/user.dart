import 'dart:io';
import 'package:discord/src/models/hashing.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:discord/src/database/Databasemanipulate.dart';

class User {
  String? uuid;
  String? username;
  String? password;
  User({required this.uuid, required this.username, required this.password});
  Map<String, dynamic> toMap() {
    return {
      'id': uuid,
      'username': username,
      'password': password,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      uuid: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }

  register(String uname) async {
    var database = Databasemanipulation();
    username = uname;
    var uidobj = Uuid();
    uuid = uidobj.v1();
    var finder = Finder(filter: Filter.equals('id', uuid));
    var finder2 = Finder(filter: Filter.equals('username', uname));
    if (await database.finder(finder, 'users') == false &&
        await database.finder(finder2, 'users') == false) {
      print("Enter password");
      var pass = stdin.readLineSync();
      password = Hashing.encoding(pass!);
      database.create(toMap(), 'users');
      print("Registration Successful");
    } else {
      print("User already exist");
    }
  }

  Future<bool> login(String uname) async {
    var database = Databasemanipulation();
    username = uname;
    var finder = Finder(filter: Filter.equals('username', uname));
    if (await database.finder(finder, 'users') == true) {
      print("Enter password");
      var pass = stdin.readLineSync();
      var map = cloneMap(await database.getdata(finder, 'users'));
      if (Hashing.check(fromMap(map).password.toString(), pass!)) {
        print("Login Successful");
        return true;
      } else {
        print("Password does not match");
        return false;
      }
    } else {
      print("User does not exist");
      return false;
    }
  }
}
