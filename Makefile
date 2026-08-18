.PHONY: validate preflight-server preflight-agent render

validate:
	./scripts/validate.sh

preflight-server:
	sudo ./scripts/preflight.sh server

preflight-agent:
	sudo ./scripts/preflight.sh agent

render:
	helm template platform-demo charts/platform-demo --namespace platform-demo
