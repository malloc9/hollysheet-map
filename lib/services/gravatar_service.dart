import 'dart:convert';
import 'package:crypto/crypto.dart';

class GravatarService {
  static String generateUrl(String email) {
    final trimmedEmail = email.trim().toLowerCase();
    final bytes = utf8.encode(trimmedEmail);
    final digest = md5.convert(bytes);
    return 'https://www.gravatar.com/avatar/$digest?d=identicon';
  }
}
