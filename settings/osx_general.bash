#!/usr/bin/env sh

echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

echo "Show hidden files in Finder"
defaults write com.apple.Finder AppleShowAllFiles -bool true

echo "Show all filename extensions in Finder"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Show Path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true

echo "Show Status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

echo 'Disable the "Are you sure you want to open this application?" dialog'
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

echo "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

echo "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Empty Trash securely by default"
defaults write com.apple.finder EmptyTrashSecurely -bool true

echo "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "Expand save panel by default"
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true

echo "Expand print panel by default"
defaults write -g PMPrintingExpandedStateForPrint -bool true

echo "Show the ~/Library folder"
chflags nohidden ~/Library

echo "Make QuickLook text selectable"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo "Remove the warning before executing downloaded files"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Disable enlarging the cursor by shaking the mouse"
defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool YES

#TODO: Ask the user if they want to restart each application (include a "yes to all" option)
echo "Restart affected applications"
for app in Safari Finder Dock SystemUIServer; do killall "$app" >/dev/null 2>&1; done
