import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:file/local.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/stalker_gamma_updater.dart' as stalker_gamma_updater;
import 'package:stalker_gamma_updater/zip_extraction_runner.dart';

void main(List<String> arguments) async {
  registerDependencies();
  configuredLogger();
  final log = Logger('MainLogger');
  log.finest('Starting main.');
  const String pathToModList = 'test/mock_modlist.txt';
  const String pathToModPackMakerList = 'test/mock_modpack_maker_list.txt';
  const String destination = 'tmp_out';
  log.finest('beginnning mods download.');
  await stalker_gamma_updater.downloadModsTo(pathToModList, pathToModPackMakerList, destination);
  log.finest('Shutting down...');
}

void registerDependencies() {
  GetIt.I.registerSingleton<ConfigurationManager>(ConfigurationManager.init());
  GetIt.I.registerLazySingleton<http.Client>(() => http.Client());
  GetIt.I.registerLazySingleton<FileSystem>(() => LocalFileSystem());
  GetIt.I.registerLazySingleton<ZipExtractionRunner>(() => ZipExtractionRunner());
}

void configuredLogger() {
  Logger.root.level = GetIt.I<ConfigurationManager>().logLevel;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}