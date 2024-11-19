import 'dart:io';

import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:stalker_gamma_updater/exceptions/platform_error.dart';
import 'package:stalker_gamma_updater/methods/checker.dart';
import 'package:stalker_gamma_updater/objects/common.dart';

mixin Downloader on Logged {
  Path? _archive;
  String _url;

  Future<Uri> download({required String to, bool useCache = true, String? hash}) async {
    // TODO: finish implementation
    _archive = _archive ?? 

    if (_archive == null) {

    }

    final client = GetIt.I<HttpClient>();
    final request = await client.getUrl(Uri.parse(to));
    final response = await request.close();

    final fs = GetIt.I<FileSystem>();
    final location = response.redirects.last.location.pathSegments.last;
    final contentLength = response.contentLength;

    final compressedFileName = Uri.parse(location).pathSegments.last;
    final outfilePath = Path('${fs.systemTempDirectory.path}/$compressedFileName');

    var sink = fs.file(outfilePath).openWrite(mode: FileMode.write);
    var totalBytesReceived = 0;
    try {
      await for (var bytes in response) {
        totalBytesReceived += bytes.length;
        sink.add(bytes);
      }
    } finally {
      sink.close();
      client.close();
      if (totalBytesReceived < contentLength) {
        log.severe(
            'Possible data corruption for "$compressedFileName". Bytes expected: $contentLength, Bytes received: $totalBytesReceived');
      }
    }

    final path = Uri.file(outfilePath, windows: Platform.isWindows);
    if (hash != null && await checkHash(path, hash)) {
      throw InvalidChecksumError(fileHash, expectedHash)
    }
  }
}
