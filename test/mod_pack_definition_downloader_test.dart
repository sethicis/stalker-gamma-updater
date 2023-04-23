// Write unit test for mod_pack_definition_downloader.dart
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/mod_pack_definition_downloader.dart';
import 'package:stalker_gamma_updater/zip_extraction_runner.dart';
import 'package:test/test.dart';

import 'mod_pack_definition_downloader_test.mocks.dart';
import 'test_helpers.dart';

// TODO: Re-write the tests in this file after updating mod_pack_definition_downloader.dart
@GenerateMocks([http.Client, ZipExtractionRunner, HttpClient])
void main() {
  group('modPackDefinitionDownloader', () {
    // These are virtual paths used with the MemoryFileSystem for testing
    final pathToModList = 'test/modlist.txt';
    final pathToMakerList = 'test/maker_list.txt';
    final testOutDir = 'test_out/';
    final mod1DirName = '2- Mod 1 Name - Mod 1 author name';
    final mod2DirName = '3- Mod 2 Name - Mod 2 Author';

    setUp(() {
      GetIt.I.registerSingleton<ConfigurationManager>(ConfigurationManager(
          maxBatchSize: 2,
          logLevel: Level.INFO,
          modPackDefinitionDestination: 'test_out/modpack_definitions',
          modPackDefinitionUrl: 'https://git.mock/mod_definitions.zip'));
      GetIt.I.registerSingleton<http.Client>(MockClient());
      final fileSystem = MemoryFileSystem();
      GetIt.I.registerSingleton<FileSystem>(fileSystem);
      GetIt.I.registerSingleton<ZipExtractionRunner>(MockZipExtractionRunner());
    });

    // Write a test for the happy path of the modPackDefinitionDownloader
    test('happy path', () async {
      final client = GetIt.I<http.Client>();
      when(client.get(Uri.parse('https://git.mock/mod_definitions.zip')))
          .thenAnswer((_) async => http.Response('<binary data>', 200));
      final zipExtractionRunner = GetIt.I<ZipExtractionRunner>();
      final MemoryFileSystem fileSystem =
          GetIt.I<FileSystem>() as MemoryFileSystem;
      final zippedFile = fileSystem.systemTempDirectory.childFile('mod-1.zip');
      final directory = filesystem.systemTempDirectory.childDirectory('out');
      when(zipExtractionRunner.extractTo(directory, zippedFile))
          .thenAnswer((_) async {});

      await modPackDefinitionDownloader();

      verify(client.get(Uri.parse('https://git.mock/mod_definitions.zip')));
      verify(zipExtractionRunner.extractZip(any, any));
    });

    // Write a test for the case where the HTTP request fails
    test('http request fails', () async {
      final client = GetIt.I<http.Client>();
      when(client.get(Uri.parse('https://git.mock/mod_definitions.zip')))
          .thenAnswer((_) async => http.Response('<binary data>', 500));

      await modPackDefinitionDownloader();

      verify(client.get(Uri.parse('https://git.mock/mod_definitions.zip')));
      verifyNever(zipExtractionRunner.extractZip(any, any));
    });

    // Write a test for the case where the zip extraction fails
    test('zip extraction fails', () async {
      final client = GetIt.I<http.Client>();
      when(client.get(Uri.parse('https://git.mock/mod_definitions.zip')))
          .thenAnswer((_) async => http.Response('<binary data>', 200));
      final zipExtractionRunner = GetIt.I<ZipExtractionRunner>();
      when(zipExtractionRunner.extractZip(any, any)).thenThrow(Exception());

      await modPackDefinitionDownloader();

      verify(client.get(Uri.parse('https://git.mock/mod_definitions.zip')));
      verify(zipExtractionRunner.extractZip(any, any));
    });
  });
  ;
}
