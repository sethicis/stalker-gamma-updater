import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalker_gamma_updater/configuration_manager.dart';
import 'package:stalker_gamma_updater/download_client.dart';
import 'package:test/test.dart';

import 'download_client_test.mocks.dart';

@GenerateMocks([http.Client, http.Response])
void main() {
  group('DownloadClient', () {
    setUp(() {
      GetIt.I.registerSingleton<FileSystem>(MemoryFileSystem());
      GetIt.I.registerSingleton<ConfigurationManager>(ConfigurationManager(
          maxBatchSize: 2,
          logLevel: Level.INFO,
          modPackDefinitionDestination: 'test_out/modpack_definitions',
          modPackDefinitionUrl: 'https://git.mock/mod_definitions.zip'));
      configuredLogger();
    });

    test('get - happy path', () async {
      final mockResponse = http.Response('<binary data>', 200, headers: {});
      final mockHttpClient = MockClient();
      final client = DownloadClient(mockHttpClient, GetIt.I<FileSystem>());
      when(mockHttpClient.get(Uri.parse('https://example.org')))
          .thenAnswer((_) async => mockResponse);
      final response = await client.get('https://example.org');
      expect(response, equals(mockResponse));
    });

    // TODO: write a functional test for the downloadFile method of DownloadClient
    // that downloads a file from https://www.learningcontainer.com/sample-zip-files/#
    // and verifies that the file was downloaded and saved to the correct location
    // (use the MemoryFileSystem for testing)
    test('downloadFile - happy path', () async {
      final mockHttpClient = MockClient();
      final fileSystem = MemoryFileSystem();
      final client = DownloadClient(mockHttpClient, fileSystem);
      final url =
          'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip';
      final file = await client.downloadFile(url);
      expect(await file?.exists(), isTrue);
      expect(await file?.length(), isNonZero);
    });
  });
}
