import 'package:file/file.dart';


Future<Map<int, IndexModInfo>> getModListIndexToNameMap(File modList) async {
  return modList.readAsLines()
    .then((List<String> lines) {
      final Map<int, IndexModInfo> modInfoMap = {};
      for (var line in lines) {
        final modInfo = _getIndexedModInfo(line);
        if (modInfo is IndexModInfo) modInfoMap.putIfAbsent(modInfo.index, () => modInfo);
      }
      return modInfoMap;
    });
}

IndexModInfo? _getIndexedModInfo(String line) {
  RegExp re = RegExp(r'^\+(\d+)-\s+(.*)\s+-\s+(\w+)$');
  final match = re.firstMatch(line);
  return match is RegExpMatch ? IndexModInfo(index: int.parse(match[1]!), title: match[2]!, author: match[3]!) : null;
}

class IndexModInfo {
  final int index;
  final String title;
  final String author;

  IndexModInfo({
    required this.index,
    required this.title,
    required this.author,
  });
}
