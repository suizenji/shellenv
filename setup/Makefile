# TODO: install docker, chrome

ifeq ($(shell uname | cut -c -5),MINGW)
sudo :=
else
sudo := sudo
endif

help:
	@echo for ubuntu 22, git sdk

apt:
	sudo apt install -y emacs-nox silversearcher-ag socat tmux

mingw:
	pacman -S --noconfirm emacs tmux

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
