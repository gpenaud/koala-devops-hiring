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

ifndef environment
$(error environment is not set)
endif

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
	terraform -chdir=environments/${environment}/layers/tfstate_backend apply -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
	terraform -chdir=environments/${environment}/layers/network 			  apply -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
	terraform -chdir=environments/${environment}/layers/database 			  apply -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
	terraform -chdir=environments/${environment}/layers/iam 						apply -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
## apply specific layer
layer-apply:
	terraform -chdir=environments/${environment}/layers/${layer} apply -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings

## destroy layers part without confirmation
layers-destroy:
	terraform -chdir=environments/${environment}/layers/iam 						destroy -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
	terraform -chdir=environments/${environment}/layers/database 			  destroy -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
	terraform -chdir=environments/${environment}/layers/network 			  destroy -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
	terraform -chdir=environments/${environment}/layers/tfstate_backend destroy -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings
## destroy specific layer
layer-destroy:
	terraform -chdir=environments/${environment}/layers/${layer} destroy -var-file ./../../../../${environment}.tfvars -auto-approve -compact-warnings

## plan high-level infrastructure
plan:
	terraform plan

## deploy high-level infrastructure
apply:
	terraform -chdir=environments/${environment} apply -var-file ./../../${environment}.tfvars -auto-approve -compact-warnings

## destroy high-level infrastructure
destroy:
	terraform -chdir=environments/${environment} destroy -var-file ./../../${environment}.tfvars -auto-approve -compact-warnings

## init all directories unless not needed
init-all:
	bash scripts/init-all.sh
	terraform init
