
import 'package:encrypt/encrypt.dart';
List<String> encryptFernet(String plain) {
  final key = Key.fromSecureRandom(32);
  var encMessage = Encrypter(Fernet(key)).encrypt(plain);
  return [key.base64,encMessage.base64];
}

String encryptFernetWithKey(String plain,String key){
  final myKey = Key.fromBase64(key);
  var encMessage = Encrypter(Fernet(myKey)).encrypt(plain);
  return encMessage.base64;
}