# steam-deck-tricks
Tips, tricks, and tweaks for SteamOS Holo.

## Installation
An all-in-one installer is currently a work in progress.

In the meantime, you can manually run the installer scripts:

```shell
cd ~/Downloads
git clone "https://github.com/eth-p/steam-deck-tricks.git"
cd steam-deck-tricks
installer/tweak_install.zsh [tweak_name]
```

## Tweaks
Installable tweaks.

### Fixes
> These are fixes to known bugs in SteamOS.
> It is recommended you install them until they're not longer needed! 

* [fix-xdg-desktop-portal](tweaks/fix-xdg-desktop-portal/): Fixes issues with links not being handled properly within Flatpak apps.

### Theme

* [chrome-dark-mode](tweaks/chrome-dark-mode/): Force Chrome to use dark mode for its UI and pages

### Quality of Life

* [chrome-graceful-shutdown](tweaks/chrome-graceful-shutdown/): Gracefully exit FlatPak Chrome on desktop mode logout
