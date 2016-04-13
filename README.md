# tackle

![alt tackle](https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Block-and-tackle-in-use.svg/200px-Block-and-tackle-in-use.svg.png)

Tackle is a local development tool for multiple Docker Compose projects interconnected via Service Discovery mechanism.
Host machine and containers use [Consul](https://hub.docker.com/r/progrium/consul/) Docker container as DNS resolver and Service Discovery agent. 
[Registrator](https://github.com/gliderlabs/registrator) is used to register docker containers to Consul.
[Docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/) and [Docker Compose](https://docs.docker.com/compose/install/) are installed during installation steps.

## Install
- Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html).
- Install bundle if not already `gem install bundle`
- run in the project's folder `bundle install`
- run in the project's folder `./tackle install` it will run Ansible's script to install Docker and Docker Compose.

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
- `setup` - Run setup steps for projects in tackle.yml
- `install` - Install Docker and Docker Compose

Example `./tackle up`

Consul UI is available at [http://localhost:8500/ui/#/dc1/services](http://localhost:8500/ui/#/dc1/services)

## tackle.yml
```yml
project1:
  root: /var/www/project1
  setup:
    - docker-compose run web bundle install
    - docker-compose run web rake db:create db:migrate db:seed

project2:
  root: /var/www/project2
  active: false
```

## Requirements
- Ruby
- Ansible

## Creating a discoverable containers
When running any container via docker, which exposes port, it will be registered in Consul.
You can access it via `container_name.service`.
To give your service a name you can follow the next example in `docker-compose.yml`

```yml
web:
  build: .
  command:  bundle exec rails s -p 3000 -b '0.0.0.0'

  environment:
    RAILS_ENV: development
    SERVICE_NAME: myservicename
```

Note that `SERVICE_NAME` should be alphanumerical and dash. No underscore or dots are allowed by DNS parser.

## Thx
Many thanks to [IFTTT/dash](https://github.com/IFTTT/dash) for mac version code inspiration.