# Chrome Dark Mode
<table><tr><td><a href="../../README.md">[Back]</a></td><td>ID: <code>chrome-dark-mode</code></td></tr></table>

This tweak forces the Flatpak version of Chrome to use dark mode.

## Why

Google Chrome is unable to detect whether the KDE theme is dark or not, and defaults to using a light theme for the browser UI and `prefers-color-scheme` CSS selector. This causes the `chrome://` pages to use a light background, and prevents supported websites from automatically enabling their dark mode.

## How

The tweak adds the following startup flags to Chrome, via the `~/.var/app/com.google.Chrome/config/chrome-flags.conf` file:

```
--enable-features=WebUIDarkMode
--force-dark-mode
```
