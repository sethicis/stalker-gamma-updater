import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:stalker_gamma_updater/stalker_gamma_updater.dart';
import 'package:test/test.dart';

import 'stalker_gamma_updater_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('downloadModsTo', () {
    // test('happy path', () async {
    //   final client = MockClient();
    //   expect(downloadModsTo(), 42);
    // });
  });
}
