# TODO: install docker, chrome

help:
	@echo for ubuntu 22

apt:
	sudo apt install -y emacs-nox silversearcher-ag socat

snap:
	sudo snap install firefox

update:
	sudo apt update && sudo apt -y upgrade
	sudo snap refresh

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
	sudo mv wsl.conf $@

conf: ~/.tmux.conf /etc/wsl.conf

clean-conf:
	sudo rm ~/.tmux.conf /etc/wsl.conf
