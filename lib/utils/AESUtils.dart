import 'dart:convert';

import 'package:encrypt/encrypt.dart';
class AESUtils {
  /// AES解密方法（与服务端Java代码对应）
  /// [encryptedData]：服务端返回的加密字符串（Base64格式）
  /// [key]：16位密钥（固定为 "12e4567t90abcdef"）
  static String decrypt(String encryptedData, String key) {
    try {
      // 1. 验证密钥长度（必须16位）
      if (key.length != 16) {
        throw ArgumentError("密钥必须是16位字符串");
      }

      // 2. Base64解码（得到包含IV和加密数据的字节数组）
      final encryptedBytes = base64.decode(encryptedData);

      // 3. 分离IV（前16字节）和实际加密数据
      if (encryptedBytes.length < 16) {
        throw FormatException("加密数据格式错误，长度不足");
      }
      final ivBytes = encryptedBytes.sublist(0, 16); // IV取前16字节
      final dataBytes = encryptedBytes.sublist(16);   // 剩余部分为加密数据

      // 4. 初始化AES参数
      final keyParam = Key.fromUtf8(key); // 密钥（16位）
      final ivParam = IV(ivBytes);       // 初始化向量（16位）
      final cipher = Encrypter(AES(
        keyParam,
        mode: AESMode.cbc,       // CBC模式
      ));

      // 5. 执行解密
      final decrypted = cipher.decrypt(Encrypted(dataBytes), iv: ivParam);

      return decrypted;
    } catch (e) {
      throw Exception("解密失败：${e.toString()}");
    }
  }
}