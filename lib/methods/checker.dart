import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:stalker_gamma_updater/objects/common.dart';

Future<bool> checkHash(Path path, String hash) async {
  final file = path.file;
  final stream = file.openRead();
  final md5hash = await md5.bind(stream).first;
  return base64.encode(md5hash.bytes) == hash;
}
