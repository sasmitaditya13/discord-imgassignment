import 'dart:io';
import 'package:discord/src/models/hashing.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:discord/src/database/Databasemanipulate.dart';
import 'package:discord/src/models/servers.dart';

class Category {
  String? catuid;
  String? cname;
  String? server;
  List<Userslist> chead;
  List<Userslist> users;
  List<Userslist> modusers;
  List<Userslist> channels;
  Category(
      {required this.catuid,
      required this.cname,
      required this.chead,
      required this.server,
      required this.channels,
      required this.users,
      required this.modusers});
  Map<String, dynamic> toMap() {
    return {
      'categoryuid': catuid,
      'categoryname': cname,
      'admin': chead.map((mod) => mod.toMap()).toList(growable: false),
      'server': server,
      'modusers': modusers.map((mod) => mod.toMap()).toList(growable: false),
      'users': users.map((mod) => mod.toMap()).toList(growable: false),
      'channels': channels.map((cat) => cat.toMap()).toList(growable: false)
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
        catuid: map['categoryuid'],
        cname: map['categoryname'],
        chead: map['admin']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>(),
        server: map['server'],
        modusers: map['modusers']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>(),
        users: map['users']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>(),
        channels: map['channels']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>());
  }

  createcategory(catname, sername, sercreator) async {
    cname = catname;
    server = sername;
    var uidobj = Uuid();
    catuid = uidobj.v1();
    var database = Databasemanipulation();
    var finder = Finder(filter: (Filter.equals('servername', server)));
    if (await database.finder(finder, 'servers') == false) {
      print("Server does not exist");
    } else {
      var map = cloneMap(await database.getdata(finder, 'servers'));
      var key = await database.getkey(finder, 'servers');
      var list = Servers.fromMap(map);
      if (list.modlist.indexWhere((element) => element.name == sercreator) !=
          -1) {
        if (list.categories.indexWhere((element) => element.name == cname) ==
            -1) {
          list.categories.add(Userslist(name: cname));
          database.delete(key, 'servers');
          final ser = Servers(
              suid: list.suid,
              sname: list.sname,
              screator: list.screator,
              modlist: list.modlist,
              userlist: list.userlist,
              categories: list.categories);
          await database.update(ser.toMap(), 'servers', key);
          modusers.add(Userslist(name: sercreator));
          users.add(Userslist(name: sercreator));
          chead.add(Userslist(name: sercreator));
          if (sercreator != list.screator) {
            modusers.add(Userslist(name: list.screator));
            users.add(Userslist(name: list.screator));
            chead.add(Userslist(name: list.screator));
          }
          await database.create(toMap(), 'categories');
        } else {
          print("This category already exist");
        }
      } else {
        print("You dont have permission");
      }
    }
  }

  addmoduser(String catname, String sername, String uname, String suser) async {
    var finder = Finder(
        filter: Filter.equals('categoryname', catname) &
            Filter.equals('server', sername));
    var finder2 = Finder(filter: Filter.equals('servername', sername));
    var database = Databasemanipulation();
    if (await database.finder(finder, 'categories') == false) {
      print("Category does not exist");
    } else {
      var key = await database.getkey(finder, 'categories');
      var map = cloneMap(await database.getdata(finder, 'categories'));
      var list = Category.fromMap(map);
      var map2 = cloneMap(await database.getdata(finder2, 'servers'));
      var list2 = Servers.fromMap(map2);
      if (list2.userlist.indexWhere((element) => element.name == uname) != -1) {
        if (list.modusers.indexWhere((element) => element.name == suser) !=
            -1) {
          catuid = list.catuid;
          cname = list.cname;
          server = list.server;
          chead = list.chead;
          modusers = list.modusers;
          users = list.users;
          channels = list.channels;
          final index = modusers.indexWhere((element) => element.name == uname);

          if (index == -1) {
            database.delete(key, 'categories');
            modusers.add(Userslist(name: uname));
            if (users.indexWhere((element) => element.name == uname) == -1) {
              users.add(Userslist(name: uname));
            }
            await database.update(toMap(), 'categories', key);
            print("Mod user added successfully");
          } else {
            print("Mod user already exists");
          }
        } else {
          print("You dont have permission to add modusers");
        }
      } else {
        print("User not present in server");
      }
    }
  }

  adduser(String catname, String sername, String uname, String suser) async {
    var finder = Finder(
        filter: Filter.equals('categoryname', catname) &
            Filter.equals('server', sername));
    var finder2 = Finder(filter: Filter.equals('servername', sername));
    var database = Databasemanipulation();
    if (await database.finder(finder, 'categories') == false) {
      print("Category does not exist");
    } else {
      var key = await database.getkey(finder, 'categories');
      var map = cloneMap(await database.getdata(finder, 'categories'));
      var list = Category.fromMap(map);
      var map2 = cloneMap(await database.getdata(finder2, 'servers'));
      var list2 = Servers.fromMap(map2);
      if (list2.userlist.indexWhere((element) => element.name == uname) != -1) {
        if (list.modusers.indexWhere((element) => element.name == suser) !=
            -1) {
          catuid = list.catuid;
          cname = list.cname;
          server = list.server;
          chead = list.chead;
          modusers = list.modusers;
          users = list.users;
          channels = list.channels;
          final index = users.indexWhere((element) => element.name == uname);
          if (index == -1) {
            database.delete(key, 'categories');
            users.add(Userslist(name: uname));
            await database.update(toMap(), 'categories', key);
            print("User added successfully");
          } else {
            print("User already exists");
          }
        } else {
          print("You dont have permission to add modusers");
        }
      } else {
        print("User not present in server");
      }
    }
  }
}
