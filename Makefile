BOXES := $(notdir $(wildcard docker/*))

PROCESS_CONTROL ?= systemd
SERVER          ?= minecraft
DOCKER_DIRECTORY:= docker
VERSION         ?= $(if $(version),$(version),)
suite_version   := $(if $(VERSION),_$(VERSION),"")

define USAGE
targets:

  all    build all Docker images (default)
  clean  remove all Docker images
  help   show this screen

machine targets:

  <machine>        build <machine> image
  <machine> clean  remove <machine> image
  <machine> test   provision and test <machine>

machines:

  $(BOXES)

variables:

  PROCESS_CONTROL   Choose from 'supervisor' or 'systemd'. Default: 'systemd'.
  SERVER            Choose from 'minecraft' or 'spigot'. Default: 'minecraft'.
endef

is_machine_target = $(if $(findstring $(firstword $(MAKECMDGOALS)),$(BOXES)),true,false)

list:
	@(echo "List of available Boxes")
	@(ls -m $(DOCKER_DIRECTORY)/ | tr ',' '\n')

build:
ifeq (true,$(call is_machine_target))
	@(echo "Preparing Build for Box: $(firstword $(MAKECMDGOALS))")
	docker-compose --file $(DOCKER_DIRECTORY)/$(firstword $(MAKECMDGOALS))/docker-compose.yml build
else
	@(echo "Preparing to Build all Boxes")
	@(\
	for test_suite in `ls -m $(DOCKER_DIRECTORY)/ | tr ',' ' '` ; do \
		docker-compose --file $(DOCKER_DIRECTORY)/$${test_suite}/docker-compose.yml build ; \
	done \
	)
endif

clean:
ifeq (true,$(call is_machine_target))
	@(echo "Preparing Cleanup for Box: $(firstword $(MAKECMDGOALS))")
	-docker images -q --filter "dangling=true" | xargs docker rmi -f
	-docker images -q molecule_local/minecraft_$(firstword $(MAKECMDGOALS)) | xargs docker rmi -f
	-docker images -q minecraft_$(firstword $(MAKECMDGOALS)) | xargs docker rmi -f
else
	-docker images -q molecule_local/minecraft* | xargs docker rmi -f
	-docker images -q minecraft_* | xargs docker rmi -f
	-docker images -q --filter "dangling=true" | xargs docker rmi -f
endif

help:
	@echo $(info $(USAGE))

test:
	@(echo "Running Molecule Tests" )
ifeq (true,$(call is_machine_target))
	@(molecule test -s $(firstword $(MAKECMDGOALS))$(suite_version))
else
	@(\
	for test_suite in $(BOXES) ; do \
		molecule test -s $${test_suite} ; \
	done \
	)
endif

$(BOXES):
	@(echo "Managing Box: $(firstword $(MAKECMDGOALS)) with action $(lastword $(MAKECMDGOALS))")
ifeq ($(firstword $(MAKECMDGOALS)),$(lastword $(MAKECMDGOALS)))
	@(echo "Default Action is build")
	docker-compose --file $(DOCKER_DIRECTORY)/$(firstword $(MAKECMDGOALS))/docker-compose.yml build
endif

.PHONY: all \
        clean \
        help \
        test \
		build \
		all \
		list
