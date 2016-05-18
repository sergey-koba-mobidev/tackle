require 'colored'

class TackleEnvironment
  MANAGERS = %w(docker config host)

  def self.build(os = 'linux')
    MANAGERS.each { |manager| require("./libs/#{os}/#{manager}_manager") }
    new(DockerManager.new, ConfigManager.new, HostManager.new)
  end

  def initialize(docker_manager, config_manager, host_manager)
    @docker_manager = docker_manager
    @config_manager = config_manager
    @host_manager = host_manager
  end

  def exit_with_error(msg)
    puts msg.red
    exit
  end

  def verify_environment
    docker_installed, error_msg = @docker_manager.installed?
    exit_with_error error_msg unless docker_installed
    exit_with_error 'Docker Compose is not installed' unless @docker_manager.compose_installed?
    exit_with_error("No #{@config_manager.config_file} file found") unless @config_manager.config_file_exists
    @docker_manager.modify_dns
    @host_manager.modify_dns @docker_manager.ip
  end

  def verify_consul_running
    @docker_manager.run_consul
    @docker_manager.run_registrator
  end

  def stop_consul
    @docker_manager.stop_consul
    @docker_manager.stop_registrator
  end

  def print_consul_uri
    puts "Go to http://#{@docker_manager.ip}:8500/ui/#/dc1/services to see discovered services".green
  end

  def run_project(project)
    pr = @config_manager.project(project)
    puts "Running docker-compose for #{project}".green
    @docker_manager.run_compose pr['root']
  end

  def run_projects
    @config_manager.with_active_projects do |title, options|
      puts "Running docker-compose for #{title}".green
      @docker_manager.run_compose options['root']
    end
  end

  def stop_project(project)
    pr = @config_manager.project(project)
    puts "Stopping docker-compose for #{project}".green
    @docker_manager.stop_compose pr['root']
  end

  def stop_projects
    @config_manager.with_active_projects do |title, options|
      puts "Stopping docker-compose for #{title}".green
      @docker_manager.stop_compose options['root']
    end
  end

  def list_projects
    @config_manager.with_all_projects do |title, options|
      puts ((options.key?('active') && !options['active']) ? "[x]".red : "[+]".green) + " #{title}"
    end
  end

  def setup_project(project)
    pr = @config_manager.project(project)
    puts "Running setup steps for #{project}".green
    if pr["setup"].size > 0
      pr["setup"].each do |cmd|
        puts "Running  #{cmd}".green
        exit_with_error("Error running  #{cmd}") unless system("cd #{pr['root']} && #{cmd}")
      end
    end
  end

  def setup_projects
    @config_manager.with_active_projects do |title, options|
      puts "Running setup steps for #{title}".green
      if options["setup"].size > 0
        options["setup"].each do |cmd|
          puts "Running  #{cmd}".green
          exit_with_error("Error running  #{cmd}") unless system("cd #{options['root']} && #{cmd}")
        end
      end
    end
  end

  def activate_project(project, state = true)
    all_projects = @config_manager.projects_list
    all_projects[project]['active'] = state
    @config_manager.save_config(all_projects)
    list_projects
  end

end