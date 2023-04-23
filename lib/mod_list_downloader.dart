import 'dart:io';

import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:io/io.dart';
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/download_client.dart';
import 'package:stalker_gamma_updater/mod_list_parser.dart';
import 'package:stalker_gamma_updater/mod_pack_list_item.dart';
import 'package:stalker_gamma_updater/zip_extraction_runner.dart';

final _log = Logger('GammaUpdater');

Future<bool> modListDownloader(String pathToModList,
    String pathToModPackMakerList, String destination) async {
  _log.finest('Running downloadModsTo');
  final fileSystem = GetIt.I<FileSystem>();

  _log.finest(
      'Current working directory is: ${fileSystem.currentDirectory.path}');
  final modListFile = fileSystem.file(pathToModList);
  final futureModInfoMap = getModListIndexToNameMap(modListFile);
  final modPackMakerListFile = fileSystem.file(pathToModPackMakerList);
  _log.info('Obtained modListFile');
  await modPackMakerListFile.readAsLines().then((List<String> lines) async {
    final batchSize = GetIt.I<ConfigurationManager>().maxBatchSize;
    List<ModPackMakerListItem> currentChunk = [];
    List<List<ModPackMakerListItem>> lineChunks = [];
    Map<int, IndexModInfo>? modInfoMap;
    for (var i = 0; i < lines.length; i++) {
      if (currentChunk.length > batchSize) {
        _log.finest(
            'Changing over to new chunk. Max batch currently: $batchSize, previous chunk size: ${currentChunk.length}');
        lineChunks.add(currentChunk);
        currentChunk = [];
      }
      _log.finest('Converting ModPack line #$i: "${lines[i]}"');
      if (modInfoMap is! Map<int, IndexModInfo>) {
        modInfoMap = await futureModInfoMap;
      }
      ModPackMakerListItem? modPackListItem;
      // Does the next indexed mod exist?
      if (modInfoMap.containsKey(i + 1)) {
        final parsed = parseModPackMakerListLine(lines[i]);
        if (parsed['url']?.isNotEmpty ?? false) {
          modPackListItem = ModPackMakerListItem.fromIndexedModInfo(
              modInfoMap[i + 1]!, parsed['url']!,
              installDirectories: parsed['subdirs'],
              modDbUrl: parsed['modDbUrl']);
        } else {
          _log.severe(
              'Failed to locate a downloadUrl for mod maker list line: ${lines[i]}.');
        }
      } else {
        modPackListItem = ModPackMakerListItem.fromString(lines[i], i + 1);
      }
      if (modPackListItem?.isValidMod ?? false) {
        _log.finest('Adding modPackItem to chunk.');
        currentChunk.add(modPackListItem!);
      }
    }
    lineChunks.add(currentChunk);
    _log.finest(
        'Beginning process of chunked lines. Number of chunks to process: ${lineChunks.length}');
    for (var chunk in lineChunks) {
      _log.finest('Processing chunk');
      List<Future<void>> futures = [];
      for (var item in chunk) {
        _log.info('Fetching mod data for: ${item.directoryName}');
        // TODO: Add a step to generate the meta.ini file for modpack list items
        // in their respective mod directories.
        futures.add(_downloadMod(item).then((zippedMod) =>
            _decompressAndMoveMod(zippedMod, item, destination)));
      }
      await Future.wait(futures);
    }
  });
  _log.finest('Leaving downloadModsTo.');
  return true;
}

String? _getMirrorUrl(response) {
  RegExp exp = RegExp(r'window.location.href="(.*?)"');
  RegExpMatch? match = exp.firstMatch(response);
  return match![1];
}

Future<File> _downloadMod(ModPackMakerListItem item) async {
  // Refactor this in the future to simply the logic and only use HttpClient instead of http.Client
  final client = GetIt.I<DownloadClientProvider>().urlClient;

  _log.finest('Requesting mirror page for: ${item.downloadUri}');
  final response = await client.get(item.downloadUri!);
  final mirrorUrl = _getMirrorUrl(response.body);
  if (mirrorUrl is! String) {
    throw ArgumentError(
        'Failed to locate mod mirror download URL for ${item.directoryName}');
  }
  _log.finest('Requesting mod download by: $mirrorUrl');
  final httpClient = HttpClient();
  final request = await httpClient.getUrl(Uri.parse(mirrorUrl));
  final mirrorResponse = await request.close();

  final fileSystem = GetIt.I<FileSystem>();
  final location = mirrorResponse.redirects.last.location.pathSegments.last;
  final contentLength = mirrorResponse.contentLength;
  if (location is! String) {
    _log.severe(
        'Could not find location header value for mirror response of: ${item.directoryName}');
    throw ('ERROR: Why is the location header missing?!');
  }

  final compressedFileName = Uri.parse(location).pathSegments.last;
  final outfileName =
      '${fileSystem.systemTempDirectory.path}/$compressedFileName';
  var sink = fileSystem.file(outfileName).openWrite(mode: FileMode.write);
  var totalBytesReceived = 0;
  try {
    await for (var bytes in mirrorResponse) {
      totalBytesReceived += bytes.length;
      sink.add(bytes);
    }
  } finally {
    sink.close();
    httpClient.close();
    if (totalBytesReceived < contentLength) {
      _log.severe(
          'Possible data corruption for "$compressedFileName". Bytes expected: $contentLength, Bytes received: $totalBytesReceived');
    }
  }

  return fileSystem.file(outfileName);
}

Future<void> _decompressAndMoveMod(
    File zippedMod, ModPackMakerListItem item, String destination) async {
  final zipExtractor = GetIt.I<ZipExtractionRunner>();
  final fileSystem = GetIt.I<FileSystem>();
  final modDir = './$destination/${item.directoryName}';
  if (item.hasSubDirectoriesToInstall) {
    _log.finest(
        'Extracting Subdirectories: ${item.subDirs} for ${item.directoryName}');
    fileSystem.directory(modDir).createSync();
    final tmpExtractDir = fileSystem.directory(
        '${fileSystem.systemTempDirectory.path}/${item.directoryName}');
    await zipExtractor.extractTo(tmpExtractDir, zippedMod);
    for (var dir in item.subDirs!) {
      _copySubfolders(tmpExtractDir.childDirectory(dir), modDir);
    }
    _copyFilesMatching(tmpExtractDir, {'changelog', 'readme'}, modDir);
    // Delete the temporary data
    tmpExtractDir.delete(recursive: true);
  } else {
    zipExtractor.extractTo(fileSystem.directory(modDir), zippedMod);
  }
}

void _copySubfolders(Directory source, String target) {
  copyPathSync(source.path, target);
}

void _copyFilesMatching(
    Directory searchDir, Set<String> searchTerms, String destination) {
  for (var file in searchDir.listSync()) {
    for (var term in searchTerms) {
      final basename = file.basename;
      if (basename.toLowerCase().startsWith(term)) {
        // TODO: Look into a better way of doing this.
        // Workaround is because file.renameSync() reports an OS error claiming
        // the file is on a different filesystem.
        GetIt.I<FileSystem>().file(file).copySync('$destination/$basename');
      }
    }
  }
}
