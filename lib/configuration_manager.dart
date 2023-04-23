import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

class ConfigurationManager {
  static final Map _levelMap = {
    'OFF': Level.OFF,
    'ALL': Level.ALL,
    'SHOUT': Level.SHOUT,
    'SEVERE': Level.SEVERE,
    'WARNING': Level.WARNING,
    'INFO': Level.INFO,
    'CONFIG': Level.CONFIG,
    'FINE': Level.FINE,
    'FINER': Level.FINER,
    'FINEST': Level.FINEST
  };
  final int maxBatchSize;
  final Level logLevel;
  final String modPackDefinitionUrl;
  final String modPackDefinitionDestination;

  ConfigurationManager({
    required this.maxBatchSize,
    required this.logLevel,
    required this.modPackDefinitionUrl,
    required this.modPackDefinitionDestination,
  });

  factory ConfigurationManager.init() {
    const modPackDefinitionDestination =
        String.fromEnvironment('MOD_PACK_DEFINITION_DESTINATION');
    const modPackDefinitionUrl =
        String.fromEnvironment('MOD_PACK_DEFINITION_URL');
    const maxBatchSize =
        int.fromEnvironment('HTTP_MAX_BATCH_SIZE', defaultValue: 10);
    const logLevelKey =
        String.fromEnvironment('LOG_LEVEL', defaultValue: 'FINEST');
    final level = _levelMap[logLevelKey.toUpperCase()];
    if (level is! Level) {
      throw ArgumentError(
          'LOG_LEVEL "$logLevelKey" does not match any known level.');
    }
    return ConfigurationManager(
        maxBatchSize: maxBatchSize,
        logLevel: level,
        modPackDefinitionUrl: modPackDefinitionUrl,
        modPackDefinitionDestination: modPackDefinitionDestination);
  }
}

void configuredLogger() {
  Logger.root.level = GetIt.I<ConfigurationManager>().logLevel;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
