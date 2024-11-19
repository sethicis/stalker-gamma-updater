import 'dart:io';

import 'package:logging/logging.dart';

abstract class Logged {
  Logger get log;
}

class Path {
  final Uri uri;
  late final File file;

  Path(String path) : uri = Uri.file(path, windows: Platform.isWindows) {
    file = File.fromUri(uri);
  }

  bool exists() {
    return file.existsSync();
  }
}
