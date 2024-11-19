import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/mod_list_parser.dart';

final _log = Logger('ModPackMakerListItem');

class ModPackMakerListItem {
  final int lineNumber;
  final Uri? downloadUri;
  final String? authorName;
  final String? title;
  final String? modDbUrl;
  final List<String>? subDirs;

  ModPackMakerListItem({
    required this.downloadUri,
    required this.title,
    required this.authorName,
    required this.lineNumber,
    required this.modDbUrl,
    required this.subDirs,
  });

  bool get isSectionDivider {
    return downloadUri is! Uri || !(downloadUri?.isAbsolute ?? false);
  }

  bool get isValidMod {
    return downloadUri is Uri &&
        (downloadUri?.isAbsolute ?? false) &&
        authorName is String &&
        title is String;
  }

  bool get hasSubDirectoriesToInstall {
    return subDirs is List;
  }

  String get directoryName {
    return '$lineNumber- $title - $authorName';
  }

  factory ModPackMakerListItem.fromString(String modpackLine, int lineNumber) {
    final parsed = parseModPackMakerListLine(modpackLine);
    final isModLine = parsed['url'] is String;
    if (isModLine) {
      _log.info('Possible ModPack Section Line: $modpackLine');
    }
    return ModPackMakerListItem(
      downloadUri: isModLine ? Uri.parse(parsed['url']!) : null,
      title: parsed['title'],
      authorName: parsed['author'],
      lineNumber: lineNumber,
      modDbUrl: parsed['modDbUrl'],
      subDirs: _getSubDirs(parsed['subdirs']),
    );
  }

  factory ModPackMakerListItem.fromIndexedModInfo(
      IndexModInfo modInfo, String downloadUrl,
      {String? installDirectories, String? modDbUrl}) {
    return ModPackMakerListItem(
      downloadUri: Uri.tryParse(downloadUrl),
      title: modInfo.title,
      authorName: modInfo.author,
      lineNumber: modInfo.index,
      modDbUrl: modDbUrl,
      subDirs: _getSubDirs(installDirectories),
    );
  }
}

Map<String, String?> parseModPackMakerListLine(String line) {
  final List<String> modMakerLineParts = line.split('\t');
  if (modMakerLineParts.length == 1) {
    return {
      'url': null,
      'subdirs': null,
      'author': null,
      'title': null,
      'modDbUrl': null
    };
  }
  final url = modMakerLineParts[0].trim();
  final subdirs = modMakerLineParts[1].trim();
  final author = modMakerLineParts[2].replaceFirst(RegExp(r'^\s+-\s+'), '');
  final title = modMakerLineParts[3].trim();
  // Get the modDbUrl from the 4th index of modMakerLineParts,
  // if the index position is set.
  final modDbUrl =
      modMakerLineParts.length > 4 ? modMakerLineParts[4].trim() : null;
  return {
    'url': url,
    'subdirs': subdirs,
    'author': author,
    'title': title,
    'modDbUrl': modDbUrl
  };
}

List<String>? _getSubDirs(String? subdirStr) {
  return (subdirStr?.isNotEmpty ?? false) && subdirStr != '0'
      ? subdirStr?.split(':')
      : null;
}
