import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter/foundation.dart' hide Key;

class EncryptHelper {
  static final _key = encrypt_lib.Key.fromLength(32);
  static final _iv = encrypt_lib.IV.fromLength(16);
  static final _encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(_key));

  static String encrypt(String text, String msgId) {
    try {
      if (text.isEmpty) return text;
      
      final encrypted = _encrypter.encrypt(text, iv: _iv);
      return encrypted.base64;
      
    } catch (e) {
      debugPrint('Error encrypting message $msgId: $e');
      return text;
    }
  }

  static String decrypt(String text, String msgId) {
    try {
      if (text.isEmpty) return text;
      
      final encrypted = encrypt_lib.Encrypted.fromBase64(text);
      return _encrypter.decrypt(encrypted, iv: _iv);
      
    } catch (e) {
      debugPrint('Error decrypting message $msgId: $e');
      return text;
    }
  }
}


// import 'package:encrypt/encrypt.dart';

// class EncryptHelper {
//   static final _iv = IV.fromLength(16);
//   static final _encrypter = Encrypter(AES(Key.fromLength(32)));

//   static String encrypt(String text) {
//     return _encrypter.encrypt(text, iv: _iv).base64;
//   }

//   static String decrypt(String encryptedText) {
//     if (encryptedText.isEmpty) return encryptedText;
//     final encrypted = Encrypted.fromBase64(encryptedText);
//     return _encrypter.decrypt(encrypted, iv: _iv);
//     //return _encrypter.decrypt64(encryptedText, iv: _iv);
//   }
// }
