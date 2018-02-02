require 'rbhive'
require 'yaml'
require 'date'

class HiveBase
  include RBHive

  def execute
    env = 'production'
    config = load_config
    # TODO: config 
    tcli_connect(config['hive'][env]['address'],
                 config['hive'][env]['port'],
                 {
                  database: config['hive'][env]['db'],
                  timeout: config['hive'][env]['time'],
                  transport: :sasl,
                  sasl_params: {
                    username: config['hive'][env]['username'],
                    password: config['hive'][env]['password']
                  }
                 }
    ) do |connect|
      yield(connect)
    end
  end

  def load_config
    YAML.load_file("#{Dir::pwd}/config/config.yml")
  end
end
