import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'dart:io';

class Databasemanipulation {
  String dbPath2 = 'sample2.db';
  DatabaseFactory dbFactory = databaseFactoryIo;

  create(var record, String type) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    await store.add(db2, record);
    db2.close();
  }

  Future<bool> finder(Finder finder, String type) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    var record = await store.findFirst(db2, finder: finder);
    db2.close();
    if (record == null) {
      return Future<bool>.value(false);
    } else {
      return Future<bool>.value(true);
    }
  }

  getdata(Finder finder, String type) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    var record = await store.findFirst(db2, finder: finder);
    db2.close();
    return record?.value;
  }

  getkey(Finder finder, String type) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    var record = await store.findFirst(db2, finder: finder);
    db2.close();
    return record?.key;
  }

  getdata2(Finder finder, String type) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    var record = await store.find(db2, finder: finder);
    db2.close();
    return record;
  }

  update(var record, String type, var key) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    await store.record(key).put(db2, record);
    db2.close();
  }

  delete(var key, String type) async {
    var store = intMapStoreFactory.store(type);
    Database db2 = await dbFactory.openDatabase(dbPath2);
    var record = store.record(key);
    await record.delete(db2);
    db2.close();
  }
}
