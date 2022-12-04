import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/mod_list_parser.dart';

final _log = Logger('ModPackMakerListItem');

class ModPackMakerListItem {
  final int lineNumber;
  final Uri? downloadUri;
  final String? authorName;
  final String? title;

  ModPackMakerListItem({
    required this.downloadUri,
    required this.title,
    required this.authorName,
    required this.lineNumber,
  });

  bool isSectionDivider() {
    return downloadUri is !Uri;
  }

  bool isValidMod() {
    return downloadUri is Uri && authorName is String && title is String;
  }

  String get directoryName {
    return '$lineNumber- $title - $authorName';
  }

  factory ModPackMakerListItem.fromString(String modpackLine, int lineNumber) {
    final match = parseModPackMakerListLine(modpackLine);
    if (match is !RegExpMatch) _log.info('Possible ModPack Section Line: $modpackLine'); 
    return ModPackMakerListItem(downloadUri: match?[1] is String ? Uri.parse(match![1]!) : null, title: match?[3], authorName: match?[2], lineNumber: lineNumber);
  }

  factory ModPackMakerListItem.fromIndexedModInfo(IndexModInfo modInfo, String downloadUrl) {
    return ModPackMakerListItem(downloadUri: Uri.parse(downloadUrl), title: modInfo.title, authorName: modInfo.author, lineNumber: modInfo.index);
  }
}

RegExpMatch? parseModPackMakerListLine(String line) {
  final RegExp reg = RegExp(r'^(https\S+).*-\s+(\w+)\s+(.*?)\s+https');
  return reg.firstMatch(line);
}