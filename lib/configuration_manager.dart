
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

  ConfigurationManager({
    required this.maxBatchSize,
    required this.logLevel,
  });

  factory ConfigurationManager.init() {
    const maxBatchSize = int.fromEnvironment('HTTP_MAX_BATCH_SIZE', defaultValue: 10);
    const logLevelKey = String.fromEnvironment('LOG_LEVEL', defaultValue: 'FINEST');
    final level = _levelMap[logLevelKey.toUpperCase()];
    if (level is !Level) throw ArgumentError('LOG_LEVEL "$logLevelKey" does not match any known level.');
    return ConfigurationManager(maxBatchSize: maxBatchSize, logLevel: level);
  }
}