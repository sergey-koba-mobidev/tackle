class DockerManager
  CONSUL_CONTAINER_NAME = 'tackleconsul'
  REGISTRATOR_CONTAINER_NAME = 'tackleregistrator'
  DOCKER_IP = '172.17.42.1'

  def ip
    DOCKER_IP
  end

  def installed?
    system("docker --version > /dev/null")
  end

  def compose_installed?
    system("docker-compose --version > /dev/null")
  end

  def container_is_running?(name)
    output = %x( docker ps -f name=#{name} )
    puts "#{name} is already running" if output.include?(name)
    output.include?(name)
  end

  def stop_container(name)
    puts 'Stop container:'.green
    system("docker stop -t 2 #{name}")
    puts 'Delete container:'.green
    system("docker rm -f #{name}")
  end

  def run_consul
    run_cmd = "docker run --name=#{CONSUL_CONTAINER_NAME} -d -p #{DOCKER_IP}:53:8600/udp -p 8400:8400 -p 8500:8500 gliderlabs/consul-server -node myconsul -bootstrap -advertise #{DOCKER_IP} -client 0.0.0.0"
    running = container_is_running?(CONSUL_CONTAINER_NAME)
    unless running
      puts "Run #{CONSUL_CONTAINER_NAME} container:".green
      system(run_cmd)
    end
  end

  def stop_consul
    stop_container CONSUL_CONTAINER_NAME
  end

  def run_registrator
    run_cmd = "docker run --name=#{REGISTRATOR_CONTAINER_NAME} -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -internal consul://#{DOCKER_IP}:8500"
    running = container_is_running?(REGISTRATOR_CONTAINER_NAME)
    unless running
      puts "Run #{REGISTRATOR_CONTAINER_NAME} container:".green
      system(run_cmd)
    end
  end

  def stop_registrator
    stop_container REGISTRATOR_CONTAINER_NAME
  end

  def run_compose(path)
    system("cd #{path} && docker-compose up -d")
  end

  def stop_compose(path)
    system("cd #{path} && docker-compose stop")
  end

  def modify_dns
    f = File.open('/etc/default/docker', 'r')
    lines = f.readlines
    f.close
    if lines.grep(/#{DOCKER_IP}/).size == 0
      system("sudo sh -c \"echo 'DOCKER_OPTS=\\\"--bip=#{DOCKER_IP}/24 --dns #{DOCKER_IP} --dns 8.8.8.8 --dns-search consul\\\"' >> /etc/default/docker\"")
      puts "Docker default options modified. (/etc/default/docker)\n".green
      system('sudo service docker restart')
    end
  end
end