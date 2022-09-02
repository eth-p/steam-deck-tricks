# Fix xdg-desktop-portal Service
<table><tr><td><a href="../../README.md">[Back]</a></td><td>ID: <code>fix-xdg-desktop-portal</code></td></tr></table>

This tweak fixes an issue where sometimes (or in my case, consistently) URLs will silently fail to open inside of Flatpak apps. This can be seen when executing custom protocol handlers within Chrome, or opening a link within Discord.

## Why

The `xdg-desktop-portal` service appears to not load correctly when switching from Gaming Mode into Desktop Mode. This is manifested by links silently failing to open when Flatpak apps such as Discord try and open a URL in the default browser.

You can positively identify this error by running `journalctl -xef` and looking for any warnings or errors with the message `MIT-MAGIC-COOKIE-1` in them.

## How

This tweak adds a friendly login script which tells KDE Plasma to restart the service when Desktop Mode is opened, thereby fixing the issue.

