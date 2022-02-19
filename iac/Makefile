## permanent variables
PROJECT			?= github.com/gpenaud/poc-lxc-terraform
RELEASE			?= $(shell git describe --tags --abbrev=0)
COMMIT			?= $(shell git rev-parse --short HEAD)
BUILD_TIME  ?= $(shell date -u '+%Y-%m-%d_%H:%M:%S')

## Colors
COLOR_RESET       = $(shell tput sgr0)
COLOR_ERROR       = $(shell tput setaf 1)
COLOR_COMMENT     = $(shell tput setaf 3)
COLOR_TITLE_BLOCK = $(shell tput setab 4)

## display this help text
help:
	@printf "\n"
	@printf "${COLOR_TITLE_BLOCK}${PROJECT} Makefile${COLOR_RESET}\n"
	@printf "\n"
	@printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	@printf " make build\n\n"
	@printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	@awk '/^[a-zA-Z\-_0-9@]+:/ { \
				helpLine = match(lastLine, /^## (.*)/); \
				helpCommand = substr($$1, 0, index($$1, ":")); \
				helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
				printf " ${COLOR_INFO}%-15s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
		{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n"

## generate layers part without confirmation
layers-apply:
	terraform -chdir=layers/tfstate_backend apply -var-file ./../../local.tfvars -auto-approve -compact-warnings
	terraform -chdir=layers/network         apply -var-file ./../../local.tfvars -auto-approve -compact-warnings
	terraform -chdir=layers/database        apply -var-file ./../../local.tfvars -auto-approve -compact-warnings
## apply specific layer
layer-apply:
	terraform -chdir=layers/${layer} apply -var-file ./../../local.tfvars -auto-approve -compact-warnings

## destroy layers part without confirmation
layers-destroy:
	terraform -chdir=layers/database        destroy -var-file ./../../local.tfvars -auto-approve -compact-warnings
	terraform -chdir=layers/network         destroy -var-file ./../../local.tfvars -auto-approve -compact-warnings
	terraform -chdir=layers/tfstate_backend destroy -var-file ./../../local.tfvars -auto-approve -compact-warnings
## destroy specific layer
layer-destroy:
	terraform -chdir=layers/${layer} destroy -var-file ./../../local.tfvars -auto-approve -compact-warnings

## plan high-level infrastructure
plan:
	terraform plan

## deploy high-level infrastructure
apply:
	terraform apply -auto-approve

## destroy high-level infrastructure
destroy:
	terraform destroy -auto-approve

## init all directories unless not needed
init-all:
	bash init-all.sh
	terraform init
