# TODO: install docker, chrome

help:
	@echo for ubuntu 22, git sdk

apt:
	apt install -y emacs-nox silversearcher-ag socat tmux

pacman:
	pacman -Syy --noconfirm emacs

snap:
	snap install firefox

~/.emacs.d:
	git clone https://github.com/suizenji/emacs.git

~/.emacs.d/init.elc: ~/.emacs.d
	cd $@ && make

emacs: ~/.emacs.d/init.elc

~/.tmux.conf:
	cp ../conf/tmux.conf $@

/etc/wsl.conf:
	@: > wsl.conf
	@echo '[boot]' >> wsl.conf
	@echo 'systemd = true' >> wsl.conf
	mv wsl.conf $@

conf: ~/.tmux.conf /etc/wsl.conf

clean:
	rm -rf ~/.emacs.d ~/.tmux.conf /etc/wsl.conf
