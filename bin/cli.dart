import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/mod_list_downloader.dart';
import 'package:stalker_gamma_updater/utils/zip_extraction_runner.dart';

void main(List<String> arguments) async {
  registerDependencies();
  configuredLogger();
  final log = Logger('MainLogger')..finest('Starting main.');
  final parser = configureArgsParser();
  final parsedArgs = parser.parse(arguments);
  log.finest('Beginnning mod downloads.');
  // TODO: Add function for downloading the latest Grok modpack definitions.
  await modListDownloader(
      parsedArgs['modList'] ?? 'test/mock_modlist.txt',
      parsedArgs['modPackList'] ?? 'test/mock_modpack_maker_list.txt',
      parsedArgs['outDir']);
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

ArgParser configureArgsParser() {
  final parser = ArgParser()
    ..addOption('modList', abbr: 'm', help: 'The path to the modList.txt file.')
    ..addOption('modPackList',
        abbr: 'p', help: 'The path to the modPackList.txt file.')
    ..addOption('outDir',
        abbr: 'o',
        defaultsTo: 'tmp_out',
        help: 'The path to the output directory.');
  return parser;
}
