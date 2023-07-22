import 'dart:io';
import 'package:discord/src/models/hashing.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:discord/src/database/Databasemanipulate.dart';

class Servers {
  String? suid;
  String? sname;
  String? screator;
  List<Userslist> modlist;
  List<Userslist> userlist;
  List<Userslist> categories;
  Servers(
      {required this.suid,
      required this.sname,
      required this.screator,
      required this.modlist,
      required this.userlist,
      required this.categories});
  Map<String, dynamic> toMap() {
    return {
      'serveruid': suid,
      'servername': sname,
      'servercreator': screator,
      'modusers': modlist.map((mod) => mod.toMap()).toList(growable: false),
      'users': userlist.map((user) => user.toMap()).toList(growable: false),
      'categories': categories.map((cat) => cat.toMap()).toList(growable: false)
    };
  }

  static Servers fromMap(Map<String, dynamic> map) {
    return Servers(
        suid: map['serveruid'],
        sname: map['servername'],
        screator: map['servercreator'],
        modlist: map['modusers']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>(),
        userlist: map['users']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>(),
        categories: map['categories']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>());
  }

  createserver(sername, sercreator) async {
    sname = sername;
    screator = sercreator;
    var uidobj = Uuid();
    suid = uidobj.v1();
    var database = Databasemanipulation();
    var finder = Finder(filter: (Filter.equals('servername', sername)));
    if (await database.finder(finder, 'servers') == false) {
      modlist.add(Userslist(name: screator));
      userlist.add(Userslist(name: screator));
      await database.create(toMap(), 'servers');
      print("Server creation Successful");
    } else {
      print("Server already exist");
    }
  }

  addmoduser(String sername, String uname, String suser) async {
    var finder = Finder(filter: Filter.equals('servername', sername));
    var database = Databasemanipulation();
    if (await database.finder(finder, 'servers') == false) {
      print("Server does not exist");
    } else {
      var key = await database.getkey(finder, 'servers');
      var map = cloneMap(await database.getdata(finder, 'servers'));
      var list = Servers.fromMap(map);
      categories = list.categories;
      suid = list.suid;
      sname = sername;
      modlist = list.modlist;
      userlist = list.userlist;
      if (suser == list.screator) {
        screator = suser;

        final index = modlist.indexWhere((element) => element.name == uname);
        if (index == -1) {
          database.delete(key, 'servers');
          modlist.add(Userslist(name: uname));
          if (userlist.indexWhere((element) => element.name == uname) == -1) {
            userlist.add(Userslist(name: uname));
          }
          await database.update(toMap(), 'servers', key);
          print("Mod user added successfully");
        } else {
          print("Mod user already exists");
        }
      } else {
        print("You dont have permission to add modusers");
      }
    }
  }

  adduser(String sername, String uname, String suser) async {
    var finder = Finder(filter: Filter.equals('servername', sername));
    var database = Databasemanipulation();
    if (await database.finder(finder, 'servers') == false) {
      print("Server does not exist");
    } else {
      var key = await database.getkey(finder, 'servers');
      var map = cloneMap(await database.getdata(finder, 'servers'));
      var list = Servers.fromMap(map);
      suid = list.suid;
      sname = sername;
      modlist = list.modlist;
      userlist = list.userlist;
      screator = list.screator;
      categories = list.categories;
      if (modlist.indexWhere((element) => element.name == suser) != -1) {
        if (userlist.indexWhere((element) => element.name == uname) == -1) {
          await database.delete(key, 'servers');
          userlist.add(Userslist(name: uname));
          await database.update(toMap(), 'servers', key);
          print("User added successfully");
        } else {
          print("User already exists");
        }
      } else {
        print("You dont have permission to add modusers");
      }
    }
  }

  prints(String sername, String suser, int i) async {
    var finder = Finder(filter: Filter.equals('servername', sername));
    var database = Databasemanipulation();
    if (await database.finder(finder, 'servers') == false) {
      print("Server does not exist");
    } else {
      var key = await database.getkey(finder, 'servers');
      var map = cloneMap(await database.getdata(finder, 'servers'));
      var list = Servers.fromMap(map);
      suid = list.suid;
      sname = sername;
      modlist = list.modlist;
      userlist = list.userlist;
      screator = list.screator;
      categories = list.categories;
      if (userlist.indexWhere((element) => element.name == suser) != -1) {
        switch (i) {
          case 1:
            {
              for (var x in userlist) {
                print(x.toMap());
              }
            }
            break;
          case 2:
            {
              for (var x in modlist) {
                print(x.toMap());
              }
            }
            break;
          case 3:
            {
              print(screator);
            }
            break;
          case 4:
            {
              for (var x in categories) {
                print(x.toMap());
              }
            }
            break;
        }
      } else {
        print("You are not an user of this server");
      }
    }
  }
}

class Userslist {
  String? name;

  Userslist({required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  static Userslist fromMap(Map<String, dynamic> map) {
    return Userslist(
      name: map['name'],
    );
  }
}
