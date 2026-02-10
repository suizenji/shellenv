block:
	$(if $(VAR),,$(error VAR is not set))

MSG :=
confirm:
	@read -p "$(MSG) (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1

sync-time:
	podman machine ssh date -u -s "\$\$(date -u +'%Y-%m-%dT%H:%M:%S')"

proxy:
	$(VM) exec -it $(NAME) socat -v 'tcp4-listen:8443,fork,reuseaddr' 'tcp4:127.0.0.1:443'
