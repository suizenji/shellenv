# TODO: install chrome
# php, symfony, composer (on vm)

ifeq ($(shell uname | cut -c -5),MINGW)
#sudo := /c/Program\ Files\ \(x86\)/gsudo/gsudo.exe
sudo :=
else
sudo := sudo
endif

help:
	@echo for ubuntu 22, git sdk, mac
#TODO arch, bsd

windows: mingw winget mingw-conf conf emacs win-bash
ubuntu: apt conf emacs
	make podman-compose watchexec
mac: brew zsh-git-comp conf emacs
	make zsh-git-comp

# https://podman.io/getting-started/installation.html#ubuntu
apt-kubic-repo := https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$$(lsb_release -rs)
apt-kubic-key := /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg
apt-kubic-list := /etc/apt/sources.list.d/devel-kubic-libcontainers-nunstable.list

apt-kubic: $(apt-kubic-key) $(apt-kubic-list)

$(apt-kubic-key):
	curl -fsSL $(apt-kubic-repo)/Release.key | gpg --dearmor | sudo tee "$@" > /dev/null
	sudo apt update && sudo apt upgrade -y

$(apt-kubic-list):
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=$(apt-kubic-key)] $(apt-kubic-repo)/ /" | sudo tee $@ > /dev/null

apt-node:
	test -e /usr/local/bin/npm || sudo apt install -y npm
	sudo npm install --global n && sudo n install lts && sudo apt remove -y nodejs npm
	sudo apt -y autoremove

apt: apt-kubic
	sudo apt install -y emacs-nox tmux silversearcher-ag socat tree global sqlite3 gdb unzip bc rlwrap markdown
	sudo apt install -y cargo && make watchexec
	sudo apt install -y expect tcllib tcl-tls
	sudo apt install -y podman qemu-system python3-pip vagrant virtualbox
	make apt-node podman-compose

~/.sh:
	mkdir -p ~/.sh

~/.sh/git-prompt.sh: ~/.sh
	curl -o $@ https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
# https://qiita.com/mikan3rd/items/d41a8ca26523f950ea9d
zsh-git-comp: ~/.sh/git-prompt.sh
	@echo '>>> next step'
	@echo source $<
	@echo 'autoload -Uz compinit && compinit'
	@echo "setopt PROMPT_SUBST ; PS1='%F{green}%n@%m%f: %F{cyan}%~%f %F{red}\$$(__git_ps1 \"(%s)\")%f"
	@echo "\\$$ '"
#	@echo '>>> bash'
#	@echo PS1="'"'\[\033]0;$$TITLEPREFIX:$$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$$'"'"

# https://brew.sh/index_ja
# https://www.macports.org/install.php
# TODO gdb, vagrant, virtualbox(arm...)
brew:
	brew install bash emacs tmux the_silver_searcher socat tree global sqlite3 unzip bc rlwrap markdown wget
	brew install watchexec
	brew install tcl-tk
	brew install podman podman-compose
	sudo port -N install tcllib
	brew install n && sudo n latest

podman-compose: ~/.local/bin/podman-compose
	@echo '>>> next step'
	@echo export PATH=\"\$$PATH:~/.local/bin\"
~/.local/bin/podman-compose:
	pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz

watchexec: ~/.cargo/bin/watchexec
	@echo '>>> next step'
	@echo export PATH=\"\$$PATH:~/.cargo/bin\"
~/.cargo/bin/watchexec:
	cargo install --locked watchexec-cli

mingw:
	pacman -S --noconfirm emacs tmux mingw64/mingw-w64-x86_64-ag socat tree global bc rlwrap wget cygutils
	pacman -S --noconfirm mingw64/mingw-w64-x86_64-watchexec
	pacman -S --noconfirm clang64/mingw-w64-clang-x86_64-nodejs
	pacman -S --noconfirm expect mingw64/mingw-w64-x86_64-tcllib
	pacman -S --noconfirm mingw64/mingw-w64-x86_64-podman mingw64/mingw-w64-x86_64-podman-compose

define winget-install
    winget list $1 || winget install $1
endef
#    winget list $1 || powershell Start-Process "winget \"install $1\"" -Verb runas

winget:
	$(call winget-install, podman)
	$(call winget-install, gsudo)
	$(call winget-install, vagrant)
	$(call winget-install, virtualbox)

mingw-conf: mingw-profile mingw-hosts

mingw-profile:
	cp ../conf/mingw-profile ~/.profile

mingw-hosts:
	echo 'mklink hosts C:\Windows\System32\drivers\etc\hosts' | gsudo cmd
	mv hosts /etc/hosts

mingw-clean:
	rm -rf ~/.profile /etc/hosts

win-bash: ~/bash.cmd
~/bash.cmd:
	@echo "C:\git-sdk-64\usr\bin\bash.exe --login" > $@

snap:
	sudo snap install firefox

pylsp:
	python3 -m pip install 'python-lsp-server[all]'

~/.emacs.d: pylsp
	git clone https://github.com/suizenji/emacs.git $@

~/.emacs.d/init.elc: ~/.emacs.d
	cd ~/.emacs.d && make

emacs: ~/.emacs.d/init.elc

/etc/wsl.conf: ../conf/wsl.conf
	sudo cp $< $@

# https://minettyo.hatenablog.com/entry/wsl_tmpfs
wsl-conf: /etc/wsl.conf
	sudo cp ../conf/fstab /etc/fstab

~/.tmux.conf: ../conf/tmux.conf
	cp $< $@

~/.gdbinit:
	wget -P ~ https://git.io/.gdbinit

~/.globalrc: ../conf/globalrc
	cp $< $@

conf: ~/.tmux.conf ~/.gdbinit ~/.globalrc

clean-emacs:
	rm -rf ~/.emacs.d

clean-conf:
	rm -rf ~/.tmux.conf ~/.gdbinit ~/.globalrc

clean-all: clean-conf clean-emacs
