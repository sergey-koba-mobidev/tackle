require './libs/base/docker_manager_base'
require 'open3'

class DockerManager < DockerManagerBase
  def ip
    stdout, stdeerr, status = Open3.capture3("docker-machine ip #{vm_name}")
    stdout
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
    system("docker-machine create --driver virtualbox #{vm_name}") unless stdout.include? vm_name

    stdout, stdeerr, status = Open3.capture3('docker ps')
    return false, "Please run 'eval $(docker-machine env #{vm_name})' and repeat tackle command." if stdeerr.include?('Cannot connect')

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