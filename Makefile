SHELL := /bin/bash

KUBE_VERSION := "1.17.4"
DOCKER_VERSION := "19.03.8"
FLANNEL_VERSION := "0.12.0"
ETCD_VERSION := "3.4.5"
SALTSTACK_VERSION := "2019.2.3"
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# binary file download way, official or nexus
DOWNLOAD_WAY := "official"

deploy:
	salt '*' saltutil.refresh_pillar
	salt '*' saltutil.refresh_modules
	salt '*' saltutil.refresh_grains
	salt '*' grains.ls
	salt '*' mine.update
	salt '*' mine.flush
	salt-run saltutil.sync_all
	salt '*' state.apply
	salt -G 'roles:ca' state.sls certificate.create
	salt -G 'roles:etcd' state.apply

download:
	@echo -e "\033[32mDownload the binaries package to ./scripts/binaries directory...\033[0m"
	@export DEBUG=$(DEBUG) \
	&& export KUBE_VERSION=$(KUBE_VERSION) \
	&& export DOCKER_VERSION=$(DOCKER_VERSION) \
	&& export FLANNEL_VERSION=$(FLANNEL_VERSION) \
	&& export ETCD_VERSION=$(ETCD_VERSION) \
	&& export CNI_VERSION=$(CNI_VERSION) \
	&& export NEXUS_HTTP_USERNAME=$(NEXUS_HTTP_USERNAME) \
	&& export NEXUS_HTTP_PASSWORD=$(NEXUS_HTTP_PASSWORD) \
	&& export NEXUS_DOMAIN_NAME=$(NEXUS_DOMAIN_NAME) \
	&& export NEXUS_REPOSITORY=$(NEXUS_REPOSITORY) \
	&& bash scripts/$(DOWNLOAD_WAY)-download.sh

init: 
	mkdir -p /srv/pillar/local /srv/salt/local
	rsync -a ./salt/* /srv/salt --delete
	rsync -a ./pillar/* /srv/pillar --delete
	rsync -a ./formulas/* /srv/formulas --delete
	salt "*" saltutil.refresh_pillar
	salt "*" saltutil.refresh_grains
	salt "*" mine.update
	# salt -G 'role:master' state.sls salt.master
	# salt -G 'role:minion' state.sls salt.minion
	# salt-run saltutil.sync_all saltenv=$(env)
	# salt -G 'roles:ca' state.apply
	# @echo "Salt $(env) env is ready in /srv/$(env)/salt. Enjoy!"

runtime:
	@tests/runtime.sh

other: 
	salt '*' pillar.data
	salt '*' pillar.get <key>
	salt '*' state.show_highstate
	salt '*' grains.items