
import 'package:encrypt/encrypt.dart';
List<String> encryptFernet(String plain) {
  final key = Key.fromSecureRandom(32);
  final fernet = Fernet(key);
  var encMessage = Encrypter(fernet).encrypt(plain);
  return [key.base64,encMessage.base64];
}