import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:file/file.dart';
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/mod_list_parser.dart';
import 'package:stalker_gamma_updater/mod_pack_list_item.dart';
import 'package:stalker_gamma_updater/zip_extraction_runner.dart';

final _log = Logger('GammaUpdater');

Future<bool> downloadModsTo(String pathToModList, String pathToModPackMakerList, String destination) async {
  _log.finest('Running downloadModsTo');
  final fileSystem = GetIt.I<FileSystem>();

  _log.finest('Current working directory is: ${fileSystem.currentDirectory.path}');
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
        _log.finest('Changing over to new chunk. Max batch currently: $batchSize, previous chunk size: ${currentChunk.length}');
        lineChunks.add(currentChunk);
        currentChunk = [];
      }
      _log.finest('Converting ModPack line #$i: "${lines[i]}"');
      if (modInfoMap is !Map<int, IndexModInfo>) {
        modInfoMap = await futureModInfoMap;
      }
      ModPackMakerListItem? modPackListItem;
      if (modInfoMap.containsKey(i+1)) {
        final matchings = parseModPackMakerListLine(lines[i]);
        if (matchings is RegExpMatch) {
          modPackListItem = ModPackMakerListItem.fromIndexedModInfo(modInfoMap[i+1]!, matchings[1]!);
        } else {
          _log.severe('Failed to locate a downloadUrl for mod maker list line: ${lines[i]}.');
        }
      } else {
        modPackListItem = ModPackMakerListItem.fromString(lines[i], i+1);
      } 
      if (modPackListItem?.isValidMod() ?? false) {
        _log.finest('Adding modPackItem to chunk.');
        currentChunk.add(modPackListItem!);
      }
    }
    lineChunks.add(currentChunk);
    _log.finest('Beginning process of chunked lines. Number of chunks to process: ${lineChunks.length}');
    for (var chunk in lineChunks) {
      _log.finest('Processing chunk');
      List<Future<void>> futures = [];
      for (var item in chunk) {
        _log.info('Fetching mod data for: ${item.directoryName}');
        futures.add(
          _downloadMod(item)
            .then((response) => _saveModToDisk(response, item))
            .then((zippedMod) => _decompressAndMoveMod(zippedMod, item, destination))
          );
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

Future<http.Response> _downloadMod(ModPackMakerListItem item) async {
  final client = GetIt.I<http.Client>();

  _log.finest('Requesting mirror page for: ${item.downloadUri}');
  final response = await client.get(item.downloadUri!);
  final mirrorUrl = _getMirrorUrl(response.body);
  if (mirrorUrl is !String) throw ArgumentError('Failed to locate mod mirror download URL for ${item.directoryName}');
  _log.finest('Requesting mod download by: $mirrorUrl');
  return client.get(Uri.parse(mirrorUrl));
}

Future<File> _saveModToDisk(http.Response response, ModPackMakerListItem modItem) async {
  final fileSystem = GetIt.I<FileSystem>();

  final temporaryFileName = '${response.request!.url.pathSegments.last}-${DateTime.now().millisecondsSinceEpoch}.zip';
  File zippedModDownload = fileSystem.file('${fileSystem.systemTempDirectory.path}/$temporaryFileName');
  _log.finest('Writing mod archive bytes for: ${modItem.directoryName}');
  return zippedModDownload.writeAsBytes(response.bodyBytes);
}

Future<void> _decompressAndMoveMod(File zippedMod, ModPackMakerListItem item, String destination) async {
  return GetIt.I<ZipExtractionRunner>().extractTo(
    GetIt.I<FileSystem>().directory('$destination/${item.directoryName}'),
    zippedMod
  );
}
