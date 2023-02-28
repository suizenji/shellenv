# TODO: install chrome
# php, symfony, composer (on vm)

ifeq ($(shell uname | cut -c -5),MINGW)
#sudo := /c/Program\ Files\ \(x86\)/gsudo/gsudo.exe
sudo :=
else
sudo := sudo
endif

help:
	@echo for ubuntu 22, git sdk
#TODO arch, bsd

windows: mingw winget mingw-conf conf emacs win-bash
ubuntu: apt-kubic apt-up apt apt-node podman-compose conf emacs

# https://podman.io/getting-started/installation.html#ubuntu
apt-kubic-repo := https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$$(lsb_release -rs)
apt-kubic-key := /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg
apt-kubic-list := /etc/apt/sources.list.d/devel-kubic-libcontainers-nunstable.list

apt-kubic: $(apt-kubic-key) $(apt-kubic-list)

$(apt-kubic-key):
	curl -fsSL $(apt-kubic-repo)/Release.key | gpg --dearmor | sudo tee "$@" > /dev/null

$(apt-kubic-list):
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=$(apt-kubic-key)] $(apt-kubic-repo)/ /" | sudo tee $@ > /dev/null

apt-node:
	test -e /usr/local/bin/npm || sudo apt install -y npm
	sudo npm install --global n && sudo n install lts && sudo apt remove -y nodejs npm
	sudo apt -y autoremove

apt-up:
	sudo apt update && sudo apt upgrade -y

apt:
	sudo apt install -y emacs-nox tmux silversearcher-ag socat tree global sqlite3 gdb unzip
	sudo apt install -y podman qemu-system python3-pip
	make podman-compose

podman-compose: ~/.local/bin/podman-compose
~/.local/bin/podman-compose:
	pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz
	@echo '>>> next'
	@echo export PATH=\"\$$PATH:~/.local/bin\"

mingw:
	pacman -S --noconfirm emacs tmux mingw64/mingw-w64-x86_64-ag socat tree global clang64/mingw-w64-clang-x86_64-nodejs
	pacman -S --noconfirm mingw64/mingw-w64-x86_64-podman mingw64/mingw-w64-x86_64-podman-compose

define winget-install
    winget list $1 || winget install $1
endef
#    winget list $1 || powershell Start-Process "winget \"install $1\"" -Verb runas

winget:
	$(call winget-install, podman)
	$(call winget-install, gsudo)

mingw-conf: mingw-profile mingw-hosts

mingw-profile:
	cp ../conf/mingw-profile ~/.profile

mingw-hosts:
	echo 'mklink hosts C:\Windows\System32\drivers\etc\hosts' | gsudo cmd
	mv hosts /etc/hosts

win-bash: ~/bash.cmd
~/bash.cmd:
	@echo "C:\git-sdk-64\usr\bin\bash.exe --login" > $@

snap:
	sudo snap install firefox

~/.emacs.d:
	git clone https://github.com/suizenji/emacs.git $@

~/.emacs.d/init.elc: ~/.emacs.d
	cd ~/.emacs.d && make

emacs: ~/.emacs.d/init.elc

~/.tmux.conf:
	cp ../conf/tmux.conf $@

/etc/wsl.conf:
	$(sudo) cp ../conf/wsl.conf $@

conf: ~/.tmux.conf /etc/wsl.conf

clean-emacs:
	rm -rf ~/.emacs.d

clean-conf:
	$(sudo) rm -rf ~/.tmux.conf /etc/wsl.conf

clean-all: clean-conf clean-emacs
