### Makefile --- Ubuntu 18.04 setup

## Author: thackl@lim4.de
## Version: $Id: Makefile,v 0.0 2018/08/24 08:53:04 thackl Exp $

## based on Dylan Taylor's template
## https://github.com/dylanmtaylor/dylan-ubuntu-makefile/blob/master/Makefile

.PHONY: all preparations essentials archives zsh fira feel tools hub perl R python chrome communication tex graphics looks

all:
	make preparations
	make essentials
	make archives
	make fira
	make feel
	make tools
	make hub
	make perl
	make R
	make chrome
	make communication
	make tex
	make graphics
	make looks

SOFTWARE=$(HOME)/software

preparations:
	sudo apt-add-repository universe
	sudo apt-add-repository multiverse
	sudo apt-add-repository restricted
	sudo apt clean all
	sudo apt update
	sudo apt -y full-upgrade
	mkdir -p $(SOFTWARE)

essentials:
	sudo apt -y install build-essential emacs elpa-async git wget curl openjdk-11-jdk\
	 gparted openssh-server sshfs make autoconf

archives:
	sudo apt -y install bzip2 pbzip2 unrar zip unzip

zsh:
	sudo apt -y install zsh
	cd /tmp && git clone https://github.com/thackl/zsh-setup.git &&\
	cd zsh-setup && ./install.sh

fira:
	cd /tmp && git clone https://github.com/mozilla/Fira;\
	sudo mkdir -p /usr/share/fonts/truetype/Fira && sudo cp Fira/ttf/* /usr/share/fonts/truetype/Fira;\
	sudo mkdir -p /usr/share/fonts/opentype/Fira && sudo cp Fira/otf/* /usr/share/fonts/opentype/Fira;\
	sudo fc-cache -fv
	gsettings set org.gnome.desktop.interface document-font-name 'Fira Sans Regular 11'
	gsettings set org.gnome.desktop.interface font-name 'Fira Sans Regular 11'
	gsettings set org.gnome.desktop.interface monospace-font-name 'Noto Mono Regular 11'
	gsettings set org.gnome.nautilus.desktop font 'Fira Sans Regular 11'


LEGACY_KEYS=org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/

feel:
	# larger fonts
	gsettings set org.gnome.desktop.interface text-scaling-factor '1.25'
	# location of buttons in window bars
	gsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize,minimize:'
	# time with date
	gsettings set org.gnome.desktop.interface clock-show-date true
	# manipulate windows
	gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Primary><Super>z']"
	gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Primary><Super>w']"
	gsettings set org.gnome.desktop.wm.keybindings maximize "['<Primary><Super>q']"
	gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Primary><Super>x']"
	gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Primary><Super>d', '<Primary><Alt>d', '<Super>d']"
	gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Primary><Super>a']"
	gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Primary><Super>s']"
	# manipulate terminal tabs
	gsettings set $(LEGACY_KEYS) prev-tab "'<Shift>Left'"
	gsettings set $(LEGACY_KEYS) next-tab "'<Shift>Right'"
	gsettings set $(LEGACY_KEYS) move-tab-left "'<Primary><Shift>Left'"
	gsettings set $(LEGACY_KEYS) move-tab-right "'<Primary><Shift>Right'"
	# color of dock indicator
	gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color "#e8e8ef"
	gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-color "#e8e8ef"
	# dual keyboard layout
	gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us'), ('xkb', 'de')]"
	gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'de')]"
	@echo Note: some modified gnome settings will only take effect after the next login

tools:
	sudo apt -y install pv keepassx vlc rename colordiff

hub:
	set -e; cd $(SOFTWARE) &&\
	latest=$$(\
	  curl -s https://api.github.com/repos/github/hub/releases/latest |\
	  grep -oP '"browser_download_url": "\K(.*)(?=")' | grep linux-amd64) &&\
	wget $$latest && tar -xzf $$(basename $$latest)

perl:
	sudo apt -y install cpanminus
	cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
	cpanm Log::Log4perl

R:
	# need some headers for manual install
	sudo apt -y install libreadline-dev zlib1g-dev libbz2-dev liblzma-dev libpcre3-dev libcurl4-openssl-dev gfortran libcairo2-dev
	# need to figure out version hidden in "latest"
	set -e; cd /tmp &&\
	wget https://cran.r-project.org/src/base/R-latest.tar.gz && tar -xzf R-latest.tar.gz;\
	Rversion=$$(tar -vtf R-latest.tar.gz | grep -om1 'R-.*$$') &&\
	cd $$Rversion && ./configure --prefix=$(SOFTWARE)/$$Rversion && make && make install
	cp .Rprofile ~/.Rprofile

Rlibs:
	sudo apt -y install libssl-dev libxml2-dev libudunits2-dev
	Rscript install-packages.R argparse tidyverse gridExtra testthat tidygraph ggforce \
	ape ggtree maps devtools
	Rscript install-github.R "thomasp85/patchwork" "thackl/thacklr"

python:
	sudo apt -y install python
	sudo apt --fix-broken install # install with all deps

chrome:
	echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo apt update
	sudo apt -y install google-chrome-stable libappindicator1 libindicator7

communication:
	sudo apt -y install thunderbird telegram-desktop
	#skype
	cd /tmp && wget https://repo.skype.com/latest/skypeforlinux-64.deb && \
	sudo dpkg -i skypeforlinux-64.deb
	sudo apt --fix-broken install # install with all deps
	#slack
	cd /tmp && wget https://downloads.slack-edge.com/linux_releases/slack-desktop-3.2.1-amd64.deb && \
	sudo dpkg -i slack-desktop-3.2.1-amd64.deb
	sudo apt --fix-broken install # install with all deps
	#bluejeans

tex:
	sudo apt -y install texlive-full latexmk

graphics:
	# gimp
	sudo apt -y install gimp
	# inkscape
	sudo add-apt-repository -y ppa:inkscape.dev/stable
	sudo apt -y install inkscape

looks:
	sudo apt -y install gnome-tweak-tool
	sudo apt -y install arc-theme
	#cd /tmp && git clone https://github.com/horst3180/arc-icon-theme --depth 1 && cd arc-icon-theme &&\
	#	./autogen.sh --prefix=/usr && sudo make install
	sudo add-apt-repository -y ppa:snwh/ppa
	sudo apt update
	sudo apt -y install moka-icon-theme

