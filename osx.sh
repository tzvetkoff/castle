#!/bin/bash

#
# colors
#

R="\033[01;31m"
G="\033[01;32m"
Y="\033[01;33m"
B="\033[01;34m"
W="\033[00;00m"

#
# question? [Y/n]
#

Q() {
	echo -ne "${Y}${*} ${B}[Y/n]${W} "
	read -n 1 -r
	echo
	if [[ ${REPLY} =~ ^[Yy]$ ]]; then
		return 0
	else
		return 1
	fi
}

#
# go!
#

if Q 'Never go into computer sleep mode?'; then
	systemsetup -setcomputersleep Off > /dev/null
fi

if Q 'Check for software updates daily, not just once per week?'; then
	defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
fi

if Q 'Disable compressed memory?'; then
	sudo nvram boot-args='vm_compressor=1'
fi

if Q 'Expanding the save panel by default?'; then
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
fi

if Q 'Saving to disk (not to iCloud) by default?'; then
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
fi

if Q 'Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window?'; then
	sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
fi

if Q 'Disable smart quotes and smart dashes as they'"'"'re annoying when typing code?'; then
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
fi

if Q 'Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs) ?'; then
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
fi

if Q 'Showing icons for hard drives, servers, and removable media on the desktop?'; then
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
fi

if Q 'Showing all filename extensions in Finder by default?'; then
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi

if Q 'Showing status bar in Finder by default?'; then
	defaults write com.apple.finder ShowStatusBar -bool true
fi

if Q 'Allowing text selection in Quick Look/Preview in Finder by default?'; then
	defaults write com.apple.finder QLEnableTextSelection -bool true
fi

if Q 'Displaying full POSIX path as Finder window title?'; then
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
fi

if Q 'Disabling the warning when changing a file extension?'; then
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
fi

if Q 'Use column view in all Finder windows by default?'; then
	defaults write com.apple.finder FXPreferredViewStyle Clmv
fi

if Q 'Avoiding the creation of .DS_Store files on network volumes?'; then
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
fi

if Q 'Adding a context menu item for showing the Web Inspector in web views?'; then
	defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
fi

#
# done
#

echo 'Done!'
