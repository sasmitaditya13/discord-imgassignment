import 'dart:io';
import 'package:discord/src/models/categories.dart';
import 'package:discord/src/models/hashing.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:discord/src/database/Databasemanipulate.dart';
import 'package:discord/src/models/servers.dart';

class Channels with Text, Voice, Announcement, Rules {
  String? chuid;
  String? chname;
  String? cname;
  String? server;
  String? ctype;
  List<Userslist> chead;
  List<Userslist> users;
  List<Userslist> modusers;
  List<Userslist> sendmessagesusers;
  Channels(
      {required this.chuid,
      required this.chname,
      required this.cname,
      required this.server,
      required this.chead,
      required this.users,
      required this.ctype, //'text''voice''rule''announcement'
      required this.modusers,
      required this.sendmessagesusers});
  Map<String, dynamic> toMap() {
    return {
      'channeluid': chuid,
      'channelname': chname,
      'categoryname': cname,
      'server': server,
      'channeltype': ctype,
      'modusers': modusers.map((mod) => mod.toMap()).toList(growable: false),
      'users': users.map((user) => user.toMap()).toList(growable: false),
      'admin': chead.map((cat) => cat.toMap()).toList(growable: false),
      'sendmessagespermission':
          sendmessagesusers.map((cat) => cat.toMap()).toList(growable: false)
    };
  }

  static Channels fromMap(Map<String, dynamic> map) {
    return Channels(
        chname: map['channelname'],
        chuid: map['categoryuid'],
        cname: map['categoryname'],
        ctype: map['channeltype'],
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
        sendmessagesusers: map['sendmessagespermission']
            .map((mapping) => Userslist.fromMap(mapping))
            .toList()
            .cast<Userslist>());
  }

  createchannel(channame, catname, sername, sercreator, cattype) async {
    chname = channame;
    server = sername;
    cname = catname;
    ctype = cattype;
    var uidobj = Uuid();
    chuid = uidobj.v1();
    var database = Databasemanipulation();
    var finder = Finder(
        filter: (Filter.equals('server', server)) &
            (Filter.equals('categoryname', cname)));
    if (await database.finder(finder, 'categories') == false) {
      print("Category does not exist");
    } else {
      var map = cloneMap(await database.getdata(finder, 'categories'));
      var key = await database.getkey(finder, 'categories');
      var list = Category.fromMap(map);
      if (list.modusers.indexWhere((element) => element.name == sercreator) !=
          -1) {
        if (list.channels.indexWhere((element) => element.name == cname) ==
            -1) {
          list.channels.add(Userslist(name: cname));
          database.delete(key, 'categories');
          final cat = Category(
              catuid: list.catuid,
              cname: list.cname,
              chead: list.chead,
              server: list.server,
              channels: list.channels,
              users: list.users,
              modusers: list.modusers);
          await database.update(cat.toMap(), 'categories', key);
          modusers = list.modusers;
          users = list.users;
          chead = list.chead;
          sendmessagesusers = modusers;
          chead.add(Userslist(name: sercreator));
          await database.create(toMap(), 'channels');
        } else {
          print("This channel already exist");
        }
      } else {
        print("You dont have permission");
      }
    }
  }

  addsendmessagesuser(String channame, String catname, String sername,
      String uname, String suser) async {
    var finder = Finder(
        filter: Filter.equals('categoryname', catname) &
            Filter.equals('server', sername) &
            Filter.equals('channelname', channame));
    var finder2 = Finder(
        filter: Filter.equals('server', sername) &
            Filter.equals('categoryname', catname));
    var database = Databasemanipulation();
    if (await database.finder(finder, 'channels') == false) {
      print("Channel does not exist");
    } else {
      var key = await database.getkey(finder, 'channels');
      var map = cloneMap(await database.getdata(finder, 'channels'));
      var list = Channels.fromMap(map);
      var map2 = cloneMap(await database.getdata(finder2, 'categories'));
      var list2 = Category.fromMap(map2);
      if (list2.users.indexWhere((element) => element.name == uname) != -1) {
        if (list.modusers.indexWhere((element) => element.name == suser) !=
            -1) {
          chuid = list.chuid;
          chname = list.chname;
          cname = list.cname;
          server = list.server;
          chead = list.chead;
          modusers = list.modusers;
          users = list.users;
          ctype = list.ctype;
          sendmessagesusers = list.sendmessagesusers;
          final index =
              sendmessagesusers.indexWhere((element) => element.name == uname);

          if (index == -1) {
            database.delete(key, 'channels');
            sendmessagesusers.add(Userslist(name: uname));
            await database.update(toMap(), 'channels', key);
            print("Sendmessage user added successfully");
          } else {
            print("Sendmessage user already exists");
          }
        } else {
          print("You dont have permission to add sendmessageuser");
        }
      } else {
        print("User not present in category");
      }
    }
  }

  sendmessages(String channame, String catname, String sername, String uname,
      String mess) async {
    var database = Databasemanipulation();
    var finder = Finder(
        filter: Filter.equals('categoryname', catname) &
            Filter.equals('server', sername) &
            Filter.equals('channelname', channame));
    if (await database.finder(finder, 'channels') == false) {
      print("Channel does not exist");
    } else {
      var map = cloneMap(await database.getdata(finder, 'channels'));
      var list = Channels.fromMap(map);
      switch (list.ctype) {
        case 'text':
          {
            if (list.sendmessagesusers
                    .indexWhere((element) => element.name == uname) ==
                -1) {
              print("User not given permission");
            } else {
              sendtextmessage(uname, sername, catname, channame, mess);
            }
          }
          break;
        case 'voice':
          {
            if (list.sendmessagesusers
                    .indexWhere((element) => element.name == uname) ==
                -1) {
              print("User not given permission");
            } else {
              sendvoicemessage(uname, sername, catname, channame, mess);
            }
          }
          break;
        case 'announcement':
          {
            if (list.modusers.indexWhere((element) => element.name == uname) ==
                -1) {
              print("User not given permission");
            } else {
              sendannouncementmessage(uname, sername, catname, channame, mess);
            }
          }
          break;
        case 'rules':
          {
            if (list.modusers.indexWhere((element) => element.name == uname) ==
                -1) {
              print("User not given permission");
            } else {
              sendrulemessage(uname, sername, catname, channame, mess);
            }
          }
          break;
        default:
          {
            print("Invalid channel type");
          }
      }
    }
  }

  seemessages(
      String channame, String catname, String sername, String uname) async {
    var database = Databasemanipulation();
    var finder = Finder(
        filter: Filter.equals('categoryname', catname) &
            Filter.equals('server', sername) &
            Filter.equals('channelname', channame));
    if (await database.finder(finder, 'channels') == false) {
      print("Channel does not exist");
    } else {
      var map = cloneMap(await database.getdata(finder, 'channels'));
      var list = Channels.fromMap(map);
      if (list.users.indexWhere((element) => element.name == uname) == -1) {
        print("You are not allowed to view messages of this channel");
      } else {
        List list = await database.getdata2(finder, 'servermessages');
        if (list.isEmpty) {
          print("No messages have been shared");
        } else {
          for (var map in list) {
            print(map);
          }
        }
      }
    }
  }
}

mixin Text {
  String? message;
  String? msender;
  String? servername;
  String? category;
  String? channel;
  String? time;
  Map<String, dynamic> toMap1() {
    return {
      'message': message,
      'channelname': channel,
      'categoryname': category,
      'server': servername,
      'messagesender': msender,
      'time': DateTime.now().toString()
    };
  }

  sendtextmessage(messsender, sername, categoryname, channelname, mess) {
    msender = messsender;
    servername = sername;
    category = categoryname;
    channel = channelname;
    message = mess;
    var database = Databasemanipulation();
    database.create(toMap1(), 'servermessages');
    print("Text message sent");
  }
}
mixin Voice {
  String? message;
  String? msender;
  String? servername;
  String? category;
  String? channel;
  String? time;
  Map<String, dynamic> toMap2() {
    return {
      'message': message,
      'channelname': channel,
      'categoryname': category,
      'server': servername,
      'messagesender': msender,
      'time': DateTime.now().toString()
    };
  }

  sendvoicemessage(messsender, servername, categoryname, channelname, mess) {
    msender = messsender;
    servername = servername;
    category = categoryname;
    channel = channelname;
    message = "VOICE MESSAGE";
    var database = Databasemanipulation();
    database.create(toMap2(), 'servermessages');
    print("Voice message sent");
  }
}
mixin Announcement {
  String? message;
  String? msender;
  String? servername;
  String? category;
  String? channel;
  String? time;
  Map<String, dynamic> toMap3() {
    return {
      'message': message,
      'channelname': channel,
      'categoryname': category,
      'server': servername,
      'messagesender': msender,
      'time': DateTime.now().toString()
    };
  }

  sendannouncementmessage(
      messsender, servername, categoryname, channelname, mess) {
    msender = messsender;
    servername = servername;
    category = categoryname;
    channel = channelname;
    message = mess;
    var database = Databasemanipulation();
    database.create(toMap3(), 'servermessages');
    print("Announcement sent");
  }
}
mixin Rules {
  String? message;
  String? msender;
  String? servername;
  String? category;
  String? channel;
  String? time;
  Map<String, dynamic> toMap4() {
    return {
      'message': message,
      'channelname': channel,
      'categoryname': category,
      'server': servername,
      'messagesender': msender,
      'time': DateTime.now().toString()
    };
  }

  sendrulemessage(messsender, servername, categoryname, channelname, mess) {
    msender = messsender;
    servername = servername;
    category = categoryname;
    channel = channelname;
    message = mess;
    var database = Databasemanipulation();
    database.create(toMap4(), 'servermessages');
    print("Rule created");
  }
}
