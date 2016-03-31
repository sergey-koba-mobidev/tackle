# tackle

Tackle is a local development tool for Ubuntu (for now) users, who have many docker-compose projects.
It uses [Consul](https://hub.docker.com/r/progrium/consul/), [Registrator](https://github.com/gliderlabs/registrator), 
[Docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/) and [Docker Compose](https://docs.docker.com/compose/install/).

## Install
Copy to any location.

## The problem
Many docker-compose projects that should be able to communicate with each other.

## What it does?
- Adds default options for new Docker's container (sets Consul as DNS for container). Containers should see each other using container name.
- Adds Consul DNS for host machine
- Creates Consul container
- Creates Registrator container
- Parses tackle.yml and runs `docker-compose up -d` or `docker-compose stop` for each project.

## Commands
- `help` - Show short help
- `up` - Runs Consul, Registrator and Docker Compose for projects in tackle.yml
- `down` - Stops Consul, Registrator and Docker Compose for projects in tackle.yml

Example `./tackle help`

## tackle.yml
```yml
project1:
  root: /var/www/project1

project2:
  root: /var/www/project2
```

## Requirements
- Ruby
- Gem yaml