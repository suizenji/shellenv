all:
	@echo 'podman build . -it name'
	@echo 'podman stop $$(docker ps -q)'
	@echo 'podman rm $$(podman ps -q -a)'
	@echo 'podman run --name php -d -it localhost/proxy-cache'
