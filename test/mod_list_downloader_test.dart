import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/mod_list_downloader.dart';
import 'package:stalker_gamma_updater/utils/zip_extraction_runner.dart';
import 'package:test/test.dart';

import 'mod_list_downloader_test.mocks.dart';
import 'test_helpers.dart';

@GenerateMocks([http.Client, ZipExtractionRunner])
void main() {
  group('modListDownloader', () {
    // These are virtual paths used with the MemoryFileSystem for testing
    final pathToModList = 'test/modlist.txt';
    final pathToMakerList = 'test/maker_list.txt';
    final testOutDir = 'test_out/';
    final mod1DirName = '2- Mod 1 Name - Mod 1 author name';
    final mod2DirName = '3- Mod 2 Name - Mod 2 Author';

    setUp(() {
      GetIt.I.registerSingleton<ConfigurationManager>(
          ConfigurationManager(maxBatchSize: 2, logLevel: Level.INFO));
      GetIt.I.registerSingleton<http.Client>(MockClient());
      final fileSystem = MemoryFileSystem();
      fileSystem
          .file(pathToModList)
          .writeAsStringSync(mockModList, flush: true);
      fileSystem
          .file(pathToMakerList)
          .writeAsStringSync(mockModPackMakerList, flush: true);
      GetIt.I.registerSingleton<FileSystem>(fileSystem);
      GetIt.I.registerSingleton<ZipExtractionRunner>(MockZipExtractionRunner());
    });
    test('happy path', () async {
      final mod1MirrorUrl =
          'www.bigfoobar.com/download/mirror/things/mod-1-mirror-download-id';
      final mod2MirrorUrl =
          'www.bigfoobar.com/download/mirror/things/mod-2-mirror-download-id';
      final client = GetIt.I<http.Client>();
      when(client.get(Uri.parse('https://www.moddb.com/addons/start/1')))
          .thenAnswer((_) async =>
              http.Response(generateDownloadPage(mod1MirrorUrl), 200));
      when(client.get(Uri.parse('https://www.moddb.com/addons/start/20')))
          .thenAnswer((_) async =>
              http.Response(generateDownloadPage(mod2MirrorUrl), 200));
      when(client.get(Uri.parse(mod1MirrorUrl))).thenAnswer((_) async =>
          http.Response('<binary data>', 200, headers: {
            'location':
                'https://download.com/source/mod-1.zip?some-extra=garbage'
          }));
      when(client.get(Uri.parse(mod2MirrorUrl))).thenAnswer((_) async =>
          http.Response('<binary data>', 200, headers: {
            'location':
                'https://download.com/source/mod-2.rar?some-extra=garbage'
          }));
      final MemoryFileSystem fileSystem =
          GetIt.I<FileSystem>() as MemoryFileSystem;
      final zippedFile = fileSystem.systemTempDirectory.childFile('mod-1.zip');
      final rarFile = fileSystem.systemTempDirectory.childFile('mod-2.rar');
      when(GetIt.I<ZipExtractionRunner>().extractTo(
              fileSystem.directory('$testOutDir/$mod1DirName'), zippedFile))
          .thenAnswer((_) async {
        await fileSystem.file('$testOutDir/$mod1DirName/mod-1.out').create();
      });
      when(GetIt.I<ZipExtractionRunner>().extractTo(
              fileSystem.directory('$testOutDir/$mod2DirName'), rarFile))
          .thenAnswer((_) async {
        await fileSystem.file('$testOutDir/$mod2DirName/mod-2.out').create();
      });

      await modListDownloader(pathToModList, pathToMakerList, testOutDir);

      expect(fileSystem.isFileSync('$testOutDir/$mod2DirName/mod-2.out'), true,
          reason: 'Failed to locate expected mod file.');
      expect(fileSystem.isFileSync('$testOutDir/$mod1DirName/mod-1.out'), true,
          reason: 'Failed to locate expected mod file.');
    },
        skip:
            'Test writing is in an incomplete state since the source code is still highly in flux.');
  });
}
