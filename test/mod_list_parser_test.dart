import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:get_it/get_it.dart';
import 'package:stalker_gamma_updater/mod_list_parser.dart';
import 'package:test/test.dart';

void main() {
  group('ModListParser', () {
    setUp(() {
      GetIt.I.registerLazySingleton<FileSystem>(() => LocalFileSystem());
    });
    test('Indexed and Nonindexed mods in list', () async {
      final modInfoMap =
          await getModListIndexToNameMap('test/mock_modlist.txt');
      for (var expectedIndex in [2, 3, 4]) {
        expect(modInfoMap.containsKey(expectedIndex), true,
            reason: 'Failed to match expected ModInfo index');
      }
      expect(modInfoMap.length, 3,
          reason: 'Found more IndexMod entries than expected.');
      expect(modInfoMap[2]?.author, 'Grokitach',
          reason: 'Mod author returned did not match expected value.');
      expect(modInfoMap[2]?.index, 2,
          reason: 'Mod index returned did not match expected value.');
      expect(modInfoMap[2]?.title, 'Main Menu Theme - Deathcard Cabin',
          reason: 'Mod title returned did not match expected value.');

      expect(modInfoMap[3]?.author, 'Solarint',
          reason: 'Mod author returned did not match expected value.');
      expect(modInfoMap[3]?.index, 3,
          reason: 'Mod index returned did not match expected value.');
      expect(modInfoMap[3]?.title, 'Soundscape Overhaul',
          reason: 'Mod title returned did not match expected value.');

      expect(modInfoMap[1], null,
          reason:
              'Section entries in the modlist shoudld not have IndexModInfo entries.');
    });
  });
}
