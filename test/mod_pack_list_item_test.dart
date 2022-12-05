import 'package:stalker_gamma_updater/mod_list_parser.dart';
import 'package:stalker_gamma_updater/mod_pack_list_item.dart';
import 'package:test/test.dart';

void main() {
  group('ModPackListItem', () {
    test('FromString - Mod Pack Item', () {
      const url = 'https://www.moddb.com/addons/start/111111';
      const authorName = 'Dadaluz';
      const modName = 'Safe Areas Transitions';
      const mockString =
          '$url	0	 - $authorName	 $modName	https://www.moddb.com/mods/stalker-anomaly/addons/safe-start1';
      const lineNumber = 222;

      final modPackItem =
          ModPackMakerListItem.fromString(mockString, lineNumber);

      expect(modPackItem.authorName, authorName,
          reason: 'AuthorName did not expected value');
      expect(modPackItem.downloadUri.toString(), url,
          reason: 'DownloadUrl did not match expected value');
      expect(modPackItem.title, modName,
          reason: 'Title did not match expected value');
      expect(modPackItem.lineNumber, lineNumber,
          reason: 'LineNumber did not match expected value');
      expect(modPackItem.isSectionDivider, false,
          reason:
              'A valid mod pack item line should not be identified as a section divider.');
      expect(modPackItem.isValidMod, true,
          reason: 'isValidMod unexpectedly returned false.');
    });
    test('FromString - Section Item', () {
      const mockString = ' special effects\t\t\t\t';
      const lineNumber = 2;

      final modPackItem =
          ModPackMakerListItem.fromString(mockString, lineNumber);

      expect(modPackItem.isSectionDivider, true,
          reason:
              'Section divider incorrectly identified as a mod pack list line item.');
    });
    test('FromIndexedModInfo', () {
      const url = 'https://www.foobar.com/things/2222';
      final modInfo = IndexModInfo(index: 2, title: 'tom', author: 'harry');
      final modPackItem = ModPackMakerListItem.fromIndexedModInfo(modInfo, url);

      expect(modPackItem.authorName, 'harry',
          reason: 'Author name failed to match expected.');
      expect(modPackItem.title, 'tom',
          reason: 'Mod title failed to match expected.');
      expect(modPackItem.lineNumber, 2,
          reason: 'Mod index failed to match expected.');
    });
  });
}
