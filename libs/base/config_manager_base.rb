require 'yaml'

class ConfigManagerBase

  def config_file
    'tackle.yml'
  end

  def config_file_exists
    File.exist?(Dir.pwd + '/' + config_file)
  end

  def projects_list
    YAML.load_file(Dir.pwd + '/' + config_file)
  end
end