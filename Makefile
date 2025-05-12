BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'
DOCKER_FLAGS = -f docker-compose.yml
DOCKER_COMPOSE = docker compose

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
	DOCKER_COMPOSE = -f docker-compose.development.yml
endif

DOCKER_BUILD_CMD = $(DOCKER_COMPOSE) $(DOCKER_FLAGS) build $(BUNDLE_FLAGS)

build: stop
	$(DOCKER_BUILD_CMD)

prebuild:
	$(DOCKER_BUILD_CMD)
	$(DOCKER_COMPOSE) up --no-start

serve:
	$(MAKE) build
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) up -d

lint:
	$(MAKE) build
	$(DOCKER_COMPOSE) run --rm app bundle exec rubocop

test:
	$(MAKE) serve
	$(DOCKER_COMPOSE) run --rm app rspec
	$(MAKE) stop

stop:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -f

update: stop
	bundle lock --update
	$(MAKE) test

.PHONY: test serve stop lint
