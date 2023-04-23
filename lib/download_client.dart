import 'dart:io';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

final _log = Logger('GammaUpdater');

class DownloadClient {
  final http.Client _urlClient;
  final FileSystem _fileSystem;

  DownloadClient(this._urlClient, this._fileSystem);

  HttpClient getDownloaderClient() {
    return HttpClient();
  }

  Future<http.Response> get(String url) async {
    final response = await _urlClient.get(Uri.parse(url));
    return response;
  }

  Future<File?> downloadFile(String url,
      {void Function(int, int)? onProgress, String? downloadDir}) async {
    final client = getDownloaderClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    final fileSystem = _fileSystem;
    final location = response.redirects.last.location.pathSegments.last;
    final contentLength = response.contentLength;
    final downloadName = Uri.parse(location).pathSegments.last;
    final destinationDir = downloadDir ?? fileSystem.systemTempDirectory.path;
    final outfileName = '$destinationDir/$downloadName';
    var sink = fileSystem.file(outfileName).openWrite(mode: FileMode.write);
    var totalBytesReceived = 0;
    File? downloadedFile;
    try {
      await for (var bytes in response) {
        totalBytesReceived += bytes.length;
        sink.add(bytes);
        if (onProgress != null) {
          onProgress(totalBytesReceived, contentLength);
        }
      }
      downloadedFile = fileSystem.file(outfileName);
    } finally {
      sink.close();
      client.close();
      if (totalBytesReceived < contentLength) {
        _log.severe(
            'Possible data corruption for "$downloadName". Bytes expected: $contentLength, Bytes received: $totalBytesReceived');
      }
    }

    return downloadedFile;
  }
}
