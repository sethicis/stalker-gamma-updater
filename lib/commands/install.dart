import 'package:args/command_runner.dart';

class InstallAnomaly extends Command {
  @override
  get name => 'Install Anomaly';

  @override
  get aliases => ['install-anomaly'];

  @override
  get description => 'Installs the Anomaly Base Game.';

  @override
  run() async {
    print('Installing Anomaly...');
    // TODO: implement installation logic for Anomaly.
    final anomalyArchive = ModdbArchive(
      "anomaly-1.5.3",
      "https://www.moddb.com/downloads/start/277404",
      "https://www.moddb.com/mods/stalker-anomaly/downloads/stalker-anomaly-153"
    )
  }
}

class InstallGamma extends Command {
  @override
  get name => 'Install Gamma';

  @override
  get aliases => ['install-gamma'];

  @override
  get description => 'Installs the Stalker Gamma Modpack.';

  @override
  run() async {
    print('Installing Gamma...');
    // TODO: implement installation logic for Gamma.
  }
}

class FullInstall extends Command {
  @override
  get name => 'Full Install';

  @override
  get aliases => ['full-install'];

  @override
  get description =>
      'Installs the Anomaly Base Game and the Stalker Gamma Modpack.';

  @override
  run() async {
    print('Installing Anomaly and Gamma...');
    await InstallAnomaly().run();
    await InstallGamma().run();
  }
}
