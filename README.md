## Description

Command line utility for updating the STALKER G.A.M.M.A. modpack.

## Why Create this CLI?

Due to how the official installer for G.A.M.M.A. was made it is currently, a huge PIA to install on Linux.  This is not Grok or anybody on the G.A.M.M.A. community's fault, STALKER Anomaly is not officially supported on Linux, so why would you put yourself through the headache of trying to make your installer compatible.
However, there is a growing community of Linux gamers / SteamDeck owners who love STALKER Anomaly and the G.A.M.M.A. modpack created for it.  The best and most consistent way of installing and updating STALKER G.A.M.M.A. on Linux right now is to use a Windows VM, then copy files over from it to Linux after updating / installing.  This is, understandably, a huge annoyance.  This project aims to improve this experience by creating an installer that's more multi-platform friendly.  This project is not meant to be a replacement for the official installer, more an alternative for those who need it.  That being said, this project is being designed from the ground up with cross-platform usage in mind.

## Road Map

- [ ] Update an existing STALKER G.A.M.M.A install by downloading the latest GAMMA_definition.zip from GitHub.
- [ ] Create a fresh install of STALKER GAMMA from the CLI in a similar manner to the official GAMMA Installer.
- [ ] Create a flatpak version of the CLI for use on SteamDecks.
- [ ] Create a new installer UI using Flutter with parity to Grok's official installer.

## Development Notes

_This section will be fleshed out more in the future._

To generate the mock files used in testing run
```
dart run build_runner build
```