import 'package:crypt/crypt.dart';

class Hashing {
  static String encoding(String pass) {
    return Crypt.sha512(pass).toString();
  }

  static bool check(String crypthash, String pass) {
    return Crypt(crypthash).match(pass);
  }
}
