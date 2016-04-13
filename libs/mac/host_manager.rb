require './libs/base/host_manager_base'

class HostManager < HostManagerBase

  def modify_dns(docker_ip)
    system("sudo sh -c 'mkdir /etc/resolver'")
    system("sudo sh -c 'touch /etc/resolver/consul'")
    f = File.open('/etc/resolver/consul', 'r')
    lines = f.readlines
    f.close
    if lines.grep(/#{docker_ip}/).size == 0
      # Prepend lines to a file
      system("sudo sh -c 'echo \"nameserver #{docker_ip}\"|cat - /etc/resolver/consul > /tmp/out && mv /tmp/out /etc/resolver/consul'")
      #system("sudo sh -c 'echo \"search consul\"|cat - /etc/resolv.conf > /tmp/out && mv /tmp/out /etc/resolv.conf'")
      puts "Host's DNS successfully modified. (/etc/resolver/consul)\n".green
    end
  end

end