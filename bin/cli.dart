import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/mod_list_downloader.dart';
import 'package:stalker_gamma_updater/zip_extraction_runner.dart';

void main(List<String> arguments) async {
  registerDependencies();
  configuredLogger();
  final log = Logger('MainLogger')..finest('Starting main.');
  // TODO: Add commands using Dart:args package which will take arguments to these operations.
  const String pathToModList = 'test/mock_modlist.txt';
  const String pathToModPackMakerList = 'test/mock_modpack_maker_list.txt';
  const String destination = 'tmp_out';
  log.finest('Beginnning mod downloads.');
  // TODO: Add function for downloading the latest Grok modpack definitions.
  await modListDownloader(pathToModList, pathToModPackMakerList, destination);
  // TODO: Add function for copying Grok mod_addons to their respective places.
  log.finest('Shutting down...');
}

void registerDependencies() {
  GetIt.I.registerSingleton<ConfigurationManager>(ConfigurationManager.init());
  GetIt.I.registerLazySingleton<http.Client>(() => http.Client());
  GetIt.I.registerLazySingleton<FileSystem>(() => LocalFileSystem());
  GetIt.I
      .registerLazySingleton<ZipExtractionRunner>(() => ZipExtractionRunner());
}

void configuredLogger() {
  Logger.root.level = GetIt.I<ConfigurationManager>().logLevel;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
