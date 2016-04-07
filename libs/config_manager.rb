require 'yaml'

class ConfigManager
  TACKLE_FILE = 'tackle.yml'

  def config_file_exists
    File.exist?(Dir.pwd + '/' + TACKLE_FILE)
  end

  def projects_list
    YAML.load_file(Dir.pwd + '/' + TACKLE_FILE)
  end
end