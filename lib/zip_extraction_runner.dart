import 'dart:io' show Platform, Process;

import 'package:file/file.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:stalker_gamma_updater/exceptions/platform_error.dart';

// Leverages third party library execution to extract archives using
// platform specific executable version of 7Zip.
class ZipExtractionRunner {
  final Logger log = Logger('ZipExtractorRunner');

  Future<void> extractTo(Directory outputDirectory, File zippedFile) async {
    log.finest('Beginning extraction of: ${zippedFile.basename}');
    _Runner command;
    if (Platform.isWindows) {
      command = _windowRunner(outputDirectory, zippedFile);
    } else if (Platform.isLinux) {
      command = _linuxRunner(outputDirectory, zippedFile);
    } else {
      throw UnsupportedPlatformError('A bundled 7zip library is not present for the Operating System you are using.');
    }

    await Process.run(command.executable, command.arguments, runInShell: true)
      .then((value) {
        if (value.exitCode == 0) {
          log.info('Extractor exited successfully for: ${zippedFile.path}');
        } else {
          log..severe('Extractor failed with exit code: ${value.exitCode}')
          ..severe('Extractor error output: ${value.stderr}')
          ..severe('Extractor output: ${value.stdout}');
        }
      });
  }

  // TODO: Double check that absolute path references will work on other computers.
  // If not, we need to replace with relative paths.
  _Runner _windowRunner(Directory outputDirectory, File zippedFile) {
    final executable = GetIt.I<FileSystem>().file('resources/windows/x64/7zip/7z.exe');
    return _Runner(executable: executable.absolute.path, arguments: ['x', zippedFile.path, '-o${outputDirectory.path}', '-y']);
  }

  _Runner _linuxRunner(Directory outputDirectory, File zippedFile) {
    final executable = GetIt.I<FileSystem>().file('resources/linux/x64/7zip/7z');
    return _Runner(executable: executable.absolute.path, arguments: ['x', zippedFile.path, '-o${outputDirectory.path}', '-y']);
  }
}

class _Runner {
  final String executable;
  final List<String> arguments;

  _Runner({
    required this.executable,
    required this.arguments,
  });
}
