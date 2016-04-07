class HostManagerBase

  # TODO: Override in OS specific class
  # Should modify hosts's DNS to point to Docker's machine ip
  def modify_dns(docker_ip)
  end

end