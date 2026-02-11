### Makefile --- Ubuntu 24.04 (Noble) setup
## Author: thackl@lim4.de
## Updated: 2026-02-11

## Notes:
## - Uses keyrings (no apt-key) for external repos
## - Uses gh instead of hub
## - Uses python3 tooling
## - Uses gnome-tweaks (not gnome-tweak-tool)
## - Uses KeepassXC (not keepassx)
## - Uses snap for Slack/Zulip (DEB-based flows are outdated)
## - R build gotchas on Noble: include common dev libs needed for building R + popular packages (curl/ssl/xml,
##   cairo/pango/harfbuzz, fonts, BLAS/LAPACK, etc.)

## 2nd pass focus:
## - GNOME 46 keybindings: avoid relying on mutter "toggle-tiled-*" (often clobbered by tiling-assistant / conflicts)
## - Ubuntu Dock vs Dash-to-Dock: Ubuntu ships a *system* “ubuntu-dock” extension, but it still uses the
##   org.gnome.shell.extensions.dash-to-dock schema; we set via schema checks / schemadir fallback.

.PHONY: all preparations essentials archives zsh fira feel tools gh perl5lib R Rlibs python chrome communication tex graphics looks tuxedo

all:
	$(MAKE) preparations
	$(MAKE) essentials
	$(MAKE) archives
	$(MAKE) fira
	$(MAKE) feel
	$(MAKE) tools
	$(MAKE) gh
	$(MAKE) perl5lib
	$(MAKE) R
	$(MAKE) Rlibs
	$(MAKE) python
	$(MAKE) chrome
	$(MAKE) communication
	$(MAKE) tex
	$(MAKE) graphics
	$(MAKE) looks
	@echo
	@echo "Done. Some GNOME settings may require logout/login to take effect."

SOFTWARE=$(HOME)/software
LEGACY_KEYS=org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/

preparations:
	sudo apt update
	sudo apt -y install software-properties-common ca-certificates curl gnupg
	sudo add-apt-repository -y universe
	sudo add-apt-repository -y multiverse
	sudo add-apt-repository -y restricted
	sudo apt clean
	sudo apt update
	sudo apt -y full-upgrade
	mkdir -p $(SOFTWARE)

essentials:
	sudo apt -y install \
		build-essential emacs elpa-async git wget curl \
		default-jdk \
		gparted openssh-server sshfs make autoconf

archives:
	sudo apt -y install bzip2 pbzip2 unrar zip unzip

zsh:
	sudo apt -y install zsh
	cd /tmp && rm -rf zsh-setup && git clone https://github.com/thackl/zsh-setup.git && \
	cd zsh-setup && ./install.sh
	@echo "# to change default shell run:"
	@echo "chsh -s /bin/zsh"
	@echo "# then log out and in again"

fira:
	cd /tmp && rm -rf Fira && git clone https://github.com/mozilla/Fira && \
	sudo mkdir -p /usr/share/fonts/truetype/Fira && sudo cp -f Fira/ttf/* /usr/share/fonts/truetype/Fira/ && \
	sudo mkdir -p /usr/share/fonts/opentype/Fira && sudo cp -f Fira/otf/* /usr/share/fonts/opentype/Fira/ && \
	sudo fc-cache -fv
	gsettings set org.gnome.desktop.interface document-font-name 'Fira Sans Regular 11' || true
	gsettings set org.gnome.desktop.interface font-name 'Fira Sans Regular 11' || true
	gsettings set org.gnome.desktop.interface monospace-font-name 'Noto Mono Regular 11' || true
	# Nautilus no longer manages the desktop in modern GNOME; keep this guarded
	gsettings set org.gnome.nautilus.desktop font 'Fira Sans Regular 11' || true

feel:
	# -------- UI basics
	gsettings set org.gnome.desktop.interface text-scaling-factor '1.25' || true
	gsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize,minimize:' || true
	gsettings set org.gnome.desktop.interface clock-show-date true || true

	# -------- Window management keybindings (GNOME 46)
	# IMPORTANT: GNOME/Ubuntu tiling behavior can be influenced by the "tiling-assistant" extension,
	# and some tiling shortcuts can get overwritten. We therefore:
	#  - keep your monitor-move shortcuts (wm.keybindings)
	#  - set maximize/unmaximize
	#  - AVOID setting mutter "toggle-tiled-left/right" (more likely to conflict / be reset)
	#
	# Move window to monitor left/right
	gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Primary><Super>z']" || true
	gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Primary><Super>x']" || true

	# Maximize / unmaximize
	gsettings set org.gnome.desktop.wm.keybindings maximize "['<Primary><Super>q']" || true
	gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Primary><Super>w']" || true

	# Show desktop
	gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Primary><Super>d', '<Primary><Alt>d', '<Super>d']" || true

	# NOTE: If you *really* want custom tiling shortcuts (left/right split) on GNOME 46,
	# the most robust approach is to configure them via the Settings UI (Keyboard -> View and Customize Shortcuts),
	# or via the tiling extension’s own settings if you use one.
	# (We intentionally do not write org.gnome.mutter.keybindings toggle-tiled-left/right here.)

	# -------- Terminal tab keybindings
	gsettings set $(LEGACY_KEYS) prev-tab "'<Shift>Left'" || true
	gsettings set $(LEGACY_KEYS) next-tab "'<Shift>Right'" || true
	gsettings set $(LEGACY_KEYS) move-tab-left "'<Primary><Shift>Left'" || true
	gsettings set $(LEGACY_KEYS) move-tab-right "'<Primary><Shift>Right'" || true

	# -------- Dock indicator colors (Ubuntu Dock vs Dash-to-Dock)
	# Ubuntu’s default dock is a *system* extension ("ubuntu-dock") derived from Dash-to-Dock and typically
	# still exposes the org.gnome.shell.extensions.dash-to-dock schema.
	#
	# We do:
	#  1) try direct gsettings if schema exists
	#  2) otherwise try schemadir fallback for the system extension location
	#
	@bash -lc '\
	  set -e; \
	  SCHEMA="org.gnome.shell.extensions.dash-to-dock"; \
	  if gsettings list-schemas | grep -qx "$$SCHEMA"; then \
	    gsettings set $$SCHEMA custom-theme-running-dots-color "#e8e8ef" || true; \
	    gsettings set $$SCHEMA custom-theme-running-dots-border-color "#e8e8ef" || true; \
	  else \
	    for D in \
	      /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com/schemas \
	      /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas \
	      $$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas \
	    ; do \
	      if [ -d "$$D" ]; then \
	        gsettings --schemadir "$$D" set $$SCHEMA custom-theme-running-dots-color "#e8e8ef" || true; \
	        gsettings --schemadir "$$D" set $$SCHEMA custom-theme-running-dots-border-color "#e8e8ef" || true; \
	        break; \
	      fi; \
	    done; \
	  fi'

	# -------- Dual keyboard layout
	gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us'), ('xkb', 'de')]" || true
	gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'de')]" || true

	@echo "Note: some modified GNOME settings will only take effect after the next login"

tools:
	sudo apt -y install pv keepassxc vlc rename colordiff dos2unix

gh:
	sudo apt -y install gh

perl5lib:
	sudo apt -y install cpanminus perl
	cpanm --local-lib=~/perl5 local::lib && eval $$(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
	cpanm Log::Log4perl

R:
	# Build deps for R itself + common "gotchas" on fresh systems when compiling popular packages (tidyverse, sf, etc.)
	# (This is intentionally a bit broader than minimal.)
	sudo apt -y install \
		build-essential gfortran \
		libreadline-dev zlib1g-dev libbz2-dev liblzma-dev \
		libpcre2-dev \
		libcurl4-openssl-dev libssl-dev \
		libxml2-dev \
		libicu-dev \
		libblas-dev liblapack-dev \
		libjpeg-dev libpng-dev libtiff-dev \
		libx11-dev libxt-dev \
		libcairo2-dev \
		libfontconfig1-dev libfreetype6-dev \
		libharfbuzz-dev libfribidi-dev \
		libpango1.0-dev \
		pkg-config

	# install latest R from source into $(SOFTWARE)/R-x.y.z
	set -e; cd /tmp && \
	rm -rf R-* && \
	wget -O R-latest.tar.gz https://cran.r-project.org/src/base/R-latest.tar.gz && \
	Rversion=$$(tar -tzf R-latest.tar.gz | head -n 1 | sed 's:/*$$::') && \
	tar -xzf R-latest.tar.gz && \
	cd $$Rversion && \
	./configure --prefix=$(SOFTWARE)/$$Rversion --enable-R-shlib && \
	$(MAKE) && sudo $(MAKE) install

	# optional user profile (expects you have a .Rprofile next to this Makefile)
	@if [ -f .Rprofile ]; then cp .Rprofile ~/.Rprofile; fi

Rlibs:
	# Additional deps often needed by CRAN packages (keep separate so base R build is not "too huge")
	sudo apt -y install \
		libudunits2-dev \
		libgdal-dev libgeos-dev libproj-dev \
		libsqlite3-dev \
		libgit2-dev

	# expects install-packages.R and install-github.R in current directory
	@if [ -f install-packages.R ]; then \
	  Rscript install-packages.R argparse tidyverse gridExtra testthat tidygraph ggforce \
	    ape ggtree maps devtools ; \
	else \
	  echo "Skipping Rlibs: install-packages.R not found"; \
	fi
	@if [ -f install-github.R ]; then \
	  Rscript install-github.R "thomasp85/patchwork" "thackl/thacklr" "thackl/gggenomes" ; \
	else \
	  echo "Skipping Rlibs (GitHub): install-github.R not found"; \
	fi

python:
	sudo apt -y install python3 python3-venv python3-pip pipx

chrome:
	sudo install -d -m 0755 /etc/apt/keyrings
	curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | \
	  sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | \
	  sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
	sudo apt update
	sudo apt -y install google-chrome-stable

communication:
	sudo apt -y install thunderbird telegram-desktop
	# Zulip Desktop (snap)
	sudo snap install zulip
	# Slack (snap; your old pinned .deb is too old)
	sudo snap install slack

tex:
	sudo apt -y install texlive-full latexmk

graphics:
	sudo apt -y install gimp
	# Use Ubuntu repo version by default (avoid PPAs unless you need bleeding-edge)
	sudo apt -y install inkscape

looks:
	sudo apt -y install gnome-tweaks arc-theme
	sudo add-apt-repository -y ppa:snwh/ppa
	sudo apt update
	sudo apt -y install moka-icon-theme
