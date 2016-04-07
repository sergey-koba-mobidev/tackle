class TackleEnvironment

  def self.build(os = 'linux')

  end

  def initialize(docker_manager, config_manager, host_manager)
    @docker_manager = docker_manager
    @config_manager = config_manager
    @host_manager = host_manager
  end
end