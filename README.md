# About

Our Backstage instance can run in three different modes:
1. `dev`: Without a build. Running in memory. 
    * Used for tests in development environment.
2. `docker`: With building and image generation. Running inside a Docker container.
3. `prod`: With building, image generation and orchestration with other services. Running in a Minikube cluster.
    * Used for mimicking a production environment.

# Dependencies

The general dependencies (probably already installed in your machine) are:
1. `curl`
2. `git`

Without a build (i.e, to run the dev mode), we need the following basic dependencies:
1. `node lts` with `yarn`.
2. `g++`, `gcc`, `make`, `libc6-dev` (or equivalent)
3. `python3`.

In the docker mode the following additional dependencies are needed:
1. `docker`

Finally, to run the prod mode, we need the following:
1. `minikube`
2. `kubectl`

> **Remarks.** 
>    * In the prod mode you really need to install Kubernetes `kubectl`: the Minikube version of `kubectl` is not enough.
>    * You can get all the above dependencies just running `sh configure.sh`.

# Install

1. clone this repo
```bash
git clone git@gitlab.luizalabs.com:cloud/opx/backstage/backstage.git
```
2. execute the configure script:
```bash
cd backstage && sh configure.sh
```

# Configuration

The main configuration file is `app-config.yml`. Additional configuration files overwrite this main file depending on the mode which is running:
```
MODE          PRIORIES
---------------------------------------
dev           app-config.local.yml 
docker        app-config.production.yml
prod          app-config.production.yml
```

The following environment variables are used. They are stored with default values in `.env.local` and copied to `.env` when executing the configure script.
```
ENV                  DESCRIPTION
----------------------------------------------
```

# Run

For each running mode, execute the following commands:
```
MODE          COMMAND
--------------------------
dev           yarn dev
docker        yarn docker
prod          yarn prod
```

# Commands

Some useful commands:
```
COMMAND               DESCRIPTION
------------------------------------------------------------------
yarn build            generate the build
yarn clean            clean the build
yarn reinstall        remove all node packages and reinstall them
yarn tsc              check typescript syntax
yarn test             run unity tests
yarn fix              run the fixer
yarn lint             run the lintier
yarn prettify         run the prettifier
```

# Contributing


