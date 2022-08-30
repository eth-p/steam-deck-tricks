# Chrome Graceful Shutdown
<table><tr><td><a href="../../README.md">[Back]</a></td><td>ID: <code>chrome-graceful-shutdown</code></td></tr></table>

This tweak configures Desktop Mode to gracefully exit Google Chrome before shutting down or returning to Gaming Mode.

## Why

Whenever exiting Desktop Mode, Google Chrome is forcefully exited. This causes a warning pop-up to show when Chrome is next opened.

## How

The tweak adds a log-out script to the user's configuration. Whenever the user is logging out (e.g. shutting down, returning the Gaming Mode), the script will politely ask Chrome to exit and wait for it to finish.
