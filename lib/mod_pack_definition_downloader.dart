import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/download_client.dart';
import 'package:stalker_gamma_updater/zip_extraction_runner.dart';

final _log = Logger('GammaUpdater');

// Rewrite this
Future<ModPackDefinition> modPackDefinitionDownloader() async {
  final modPackDefinitionDestination =
      GetIt.I<ConfigurationManager>().modPackDefinitionDestination;
  final modPackDefinitionUrl =
      GetIt.I<ConfigurationManager>().modPackDefinitionUrl;
  final client = GetIt.I<DownloadClient>();
  final downloadedArchive = await client.downloadFile(modPackDefinitionUrl);
  // Extract the mod pack defintion zip_extraction_runner then return the modPackDefinition
  final fileSystem = GetIt.I<FileSystem>();
  final zipExtractor = GetIt.I<ZipExtractionRunner>();
  final extractDir = fileSystem.directory(modPackDefinitionDestination);
  // TODO: Re-write the downloadFile method to throw an exception when a file cannot be returned.
  await zipExtractor.extractTo(extractDir, downloadedArchive!);
  _log.finest(
      'Mod pack definition downloaded to $modPackDefinitionDestination');

  return ModPackDefinition(
      pathToModPackMakerList:
          '$modPackDefinitionDestination/G.A.M.M.A/modpack_data/modpack_maker_list.txt',
      pathToModList:
          '$modPackDefinitionDestination/G.A.M.M.A/modpack_data/modlist.txt',
      pathToModPackAddons:
          '$modPackDefinitionDestination/G.A.M.M.A/modpack_addons');
}

class ModPackDefinition {
  ModPackDefinition(
      {required final String pathToModPackMakerList,
      required final String pathToModList,
      required final String pathToModPackAddons});
}
