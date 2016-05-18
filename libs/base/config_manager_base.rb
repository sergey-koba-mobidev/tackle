require 'yaml'

class ConfigManagerBase

  def config_file
    'tackle.yml'
  end

  def config_file_exists
    File.exist?(Dir.pwd + '/' + config_file)
  end

  def save_config(data)
    File.open(config_file, 'w') {|f| f.write data.to_yaml }
  end

  def projects_list
    YAML.load_file(Dir.pwd + '/' + config_file)
  end

  def project(title)
    list = YAML.load_file(Dir.pwd + '/' + config_file)
    list[title]
  end

  def with_active_projects
    projects_list.each do |title, options|
      next if options.key?('active') && !options['active']
      yield title, options
    end
  end

  def with_all_projects
    projects_list.each do |title, options|
      yield title, options
    end
  end
end