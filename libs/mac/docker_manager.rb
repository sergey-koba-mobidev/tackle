require './libs/base/docker_manager_base'
require 'open3'

class DockerManager < DockerManagerBase
  def ip
    stdout, stdeerr, status = Open3.capture3("docker-machine ip #{vm_name}")
    stdout.strip
  end

  def vm_name
    'tackle'
  end

  def modify_dns
  end

  def installed?
    result = system('VBoxManage --version > /dev/null')
    return result, 'VirtualBox is not installed.' unless result

    stdout, stdeerr, status = Open3.capture3('VBoxManage list vms')
    unless stdout.include? vm_name
      system("docker-machine create --driver virtualbox --virtualbox-memory 4096 #{vm_name}")
      system("ansible-playbook ./ansible/darwin_nfs.yml -i 127.0.0.1, --ask-sudo-pass --verbose --extra-vars 'docker_machine_ip=#{ip}'")
      system("docker-machine scp docker/bootsync.sh #{vm_name}:/tmp/bootsync.sh")
      system("docker-machine ssh #{vm_name} \"sudo mv /tmp/bootsync.sh /var/lib/boot2docker/bootsync.sh\"")
      system("docker-machine stop #{vm_name}")
      system("docker-machine start #{vm_name}")
    end

    stdout, stdeerr, status = Open3.capture3('VBoxManage list runningvms')
    unless stdout.include? vm_name
      system("VBoxManage startvm #{vm_name} --type headless")
    end

    stdout, stdeerr, status = Open3.capture3('docker ps')
    return false, "Please run 'eval $(docker-machine env #{vm_name})' and repeat tackle command. If eval returned error wait until VM is up and repeat eval." if stdeerr.include?('Cannot connect')

    return true, ''
  end

  def run_registrator
    run_cmd = "docker run --name=#{REGISTRATOR_CONTAINER_NAME} -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip #{ip} consul://#{ip}:8500"
    running = container_is_running?(REGISTRATOR_CONTAINER_NAME)
    unless running
      puts "Run #{REGISTRATOR_CONTAINER_NAME} container:".green
      system(run_cmd)
    end
  end
end