require './libs/base/docker_manager_base'

class DockerManager < DockerManagerBase
  def ip
    '172.17.42.1'
  end

  def modify_dns
    f = File.open('/etc/default/docker', 'r')
    lines = f.readlines
    f.close
    if lines.grep(/#{ip}/).size == 0
      system("sudo sh -c \"echo 'DOCKER_OPTS=\\\"--bip=#{ip}/24 --dns #{ip} --dns 8.8.8.8 --dns-search consul\\\"' >> /etc/default/docker\"")
      puts "Docker default options modified. (/etc/default/docker)\n".green
      system('sudo service docker restart')
    end
  end
end