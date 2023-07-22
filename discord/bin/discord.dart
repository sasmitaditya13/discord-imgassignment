import 'package:args/args.dart';
import 'package:discord/discord.dart' as discord;
import 'package:discord/src/models/categories.dart';
import 'package:discord/src/models/channels.dart';
import 'package:discord/src/models/dms.dart';
import 'package:discord/src/models/servers.dart';
import 'dart:io';
import 'package:discord/src/models/user.dart';

void main(List<String> args) async {
  final user = User(uuid: null, username: null, password: null);
  var parser = ArgParser();
  parser.addOption('register');
  parser.addOption('login');
  var results = parser.parse(args);
  // parser.addOption('register', callback: User().insert(results));
  if (results.wasParsed('register')) {
    user.register(results['register']);
  }
  if (results.wasParsed('login')) {
    if (await user.login(results['login'])) {
      print("Enter further commands");
      String commands = stdin.readLineSync().toString();
      main2(commands.split(' '), results['login']);
    }
  }
}

void main2(List<String> args, String usern) async {
  var parser = ArgParser();
  parser.addOption('senddm');
  parser.addOption('seedms');
  parser.addOption('cserver');
  parser.addOption('addu');
  parser.addOption('addmodu');
  parser.addOption('addcat');
  parser.addOption('addmodcat');
  parser.addOption('addusercat');
  parser.addOption('addch');
  parser.addOption('addsendch');
  parser.addOption('sendmess');
  parser.addOption('seemess');
  parser.addOption('printuserserver');
  parser.addOption('printmoduserserver');
  parser.addOption('printservercreator');
  // parser.addOption('printusercategory');
  // parser.addOption('printmodusercategory');          //Will add later brownie
  // parser.addOption('printadmincategory');
  // parser.addOption('printsendmessagechannel');
  parser.addOption('logout');
  parser.addOption('printcategorylist');
  final dms = Dms(msender: null, mreciever: null, message: null, time: null);
  final ser = Servers(
      suid: null,
      sname: null,
      screator: null,
      modlist: [],
      userlist: [],
      categories: []);
  final cat = Category(
      catuid: null,
      cname: null,
      chead: [],
      server: null,
      channels: [],
      users: [],
      modusers: []);
  final ch = Channels(
      chuid: null,
      chname: null,
      cname: null,
      server: null,
      chead: [],
      users: [],
      ctype: null,
      modusers: [],
      sendmessagesusers: []);
  var results = parser.parse(args);

  if (results.wasParsed('senddm')) {
    String mreciever = results['senddm'];
    await dms.sendmessage(mreciever, usern);
  }
  if (results.wasParsed('seedms')) {
    String mreciever = results['seedms'];
    await dms.seedms(mreciever, usern);
  }
  if (results.wasParsed('cserver')) {
    String servername = results['cserver'];
    await ser.createserver(servername, usern);
  }
  if (results.wasParsed('addmodu')) {
    String servername = results['addmodu'];
    print("Enter user to be added");
    String uadd = stdin.readLineSync().toString();
    await ser.addmoduser(servername, uadd, usern);
  }
  if (results.wasParsed('addu')) {
    String servername = results['addu'];
    print("Enter user to be added");
    String uadd = stdin.readLineSync().toString();
    await ser.adduser(servername, uadd, usern);
  }
  if (results.wasParsed('addcat')) {
    String servername = results['addcat'];
    print("Enter category name");
    String catname = stdin.readLineSync().toString();
    await cat.createcategory(catname, servername, usern);
  }
  if (results.wasParsed('addmodcat')) {
    String servername = results['addmodcat'];
    print("Enter category name");
    String catname = stdin.readLineSync().toString();
    print("Enter user to add");
    String usertoadd = stdin.readLineSync().toString();
    await cat.addmoduser(catname, servername, usertoadd, usern);
  }
  if (results.wasParsed('addusercat')) {
    String servername = results['addusercat'];
    print("Enter category name");
    String catname = stdin.readLineSync().toString();
    print("Enter user to add");
    String usertoadd = stdin.readLineSync().toString();
    await cat.adduser(catname, servername, usertoadd, usern);
  }
  if (results.wasParsed('addch')) {
    String servername = results['addch'];
    print(
        "Enter Category name \nEnter 'null' if channel does not have category");
    String catname = stdin.readLineSync().toString();
    print("Enter channel name");
    String chname = stdin.readLineSync().toString();
    print(
        "Enter channel type \nA channel is of one of the following types \ntext \nannouncement \nrules \nvoice");
    String chtype = stdin.readLineSync().toString();
    if (chtype == 'text' ||
        chtype == 'announcement' ||
        chtype == 'voice' ||
        chtype == 'rules') {
      await ch.createchannel(chname, catname, servername, usern, chtype);
    } else {
      print("Invalid Channel type");
    }
  }
  if (results.wasParsed('addsendch')) {
    String servername = results['addsendch'];
    print(
        "Enter Category name \nEnter 'null' if channel does not have category");
    String catname = stdin.readLineSync().toString();
    print("Enter channel name");
    String chname = stdin.readLineSync().toString();
    print("Enter user to be added");
    String useradd = stdin.readLineSync().toString();
    await ch.addsendmessagesuser(chname, catname, servername, useradd, usern);
  }
  if (results.wasParsed('sendmess')) {
    String servername = results['sendmess'];
    print(
        "Enter Category name \nEnter 'null' if channel does not have category");
    String catname = stdin.readLineSync().toString();
    print("Enter channel name");
    String chname = stdin.readLineSync().toString();
    print("Enter message");
    String mess = stdin.readLineSync().toString();
    await ch.sendmessages(chname, catname, servername, usern, mess);
  }
  if (results.wasParsed('seemess')) {
    String servername = results['seemess'];
    print(
        "Enter Category name \nEnter 'null' if channel does not have category");
    String catname = stdin.readLineSync().toString();
    print("Enter channel name");
    String chname = stdin.readLineSync().toString();
    await ch.seemessages(chname, catname, servername, usern);
  }
  if (results.wasParsed('printuserserver')) {
    String servername = results['printuserserver'];
    await ser.prints(servername, usern, 1);
  }
  if (results.wasParsed('printmoduserserver')) {
    String servername = results['printmoduserserver'];
    await ser.prints(servername, usern, 2);
  }
  if (results.wasParsed('printservercreator')) {
    String servername = results['printservercreator'];
    await ser.prints(servername, usern, 3);
  }
  if (results.wasParsed('printcategorylist')) {
    String servername = results['printcategorylist'];
    await ser.prints(servername, usern, 4);
  }
  if (results.wasParsed('logout')) {
    return null;
  }
  String commands = stdin.readLineSync().toString();
  main2(commands.split(' '), usern);
}
