# TODO: install chrome
# php, symfony, composer (on vm)

ifeq ($(shell uname | cut -c -5),MINGW)
sudo := /c/Program\ Files\ \(x86\)/gsudo/gsudo.exe
else
sudo := sudo
endif

help:
	@echo for ubuntu 22, git sdk
#TODO arch, bsd

# https://podman.io/getting-started/installation.html#ubuntu
apt-kubic-repo := https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$$(lsb_release -rs)
apt-kubic-key := /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg
apt-kubic-list := /etc/apt/sources.list.d/devel-kubic-libcontainers-nunstable.list

apt-kubic: $(apt-kubic-key) $(apt-kubic-list)
	sudo apt update

$(apt-kubic-key):
	curl -fsSL $(apt-kubic-repo)/Release.key | gpg --dearmor | sudo tee "$@" > /dev/null

$(apt-kubic-list):
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=$(apt-kubic-key)] $(apt-kubic-repo)/ /" | sudo tee $@ > /dev/null

apt-node:
	test -e /usr/local/bin/npm || sudo apt install -y npm
	sudo npm install --global n && sudo n install lts && sudo apt remove -y nodejs npm
	sudo apt -y autoremove

apt: apt-kubic apt-node
	sudo apt install -y emacs-nox tmux silversearcher-ag socat tree global podman qemu-system sqlite3

mingw:
	pacman -S --noconfirm emacs tmux mingw64/mingw-w64-x86_64-ag socat tree global clang64/mingw-w64-clang-x86_64-nodejs mingw64/mingw-w64-x86_64-podman
	@echo '>>> Node.js config'
	@echo export NODE_SKIP_PLATFORM_CHECK=1
	@echo export PATH=\"\$$PATH:/clang64/bin\"

gsudo:
	powershell Start-Process "winget \"install gsudo\"" -Verb runas

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
