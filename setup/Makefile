# TODO: install docker, chrome

ifeq ($(shell uname | cut -c -5),MINGW)
sudo := /c/Program\ Files\ \(x86\)/gsudo/gsudo.exe
else
sudo := sudo
endif

help:
	@echo for ubuntu 22, git sdk

apt:
	sudo apt install -y emacs-nox tmux silversearcher-ag socat tree

mingw:
	pacman -S --noconfirm emacs tmux mingw64/mingw-w64-x86_64-ag socat tree mingw64/mingw-w64-x86_64-nodejs

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
	@: > wsl.conf
	@echo '[boot]' >> wsl.conf
	@echo 'systemd = true' >> wsl.conf
	$(sudo) mv wsl.conf $@

conf: ~/.tmux.conf /etc/wsl.conf

clean:
	$(sudo) rm -rf ~/.emacs.d ~/.tmux.conf /etc/wsl.conf
