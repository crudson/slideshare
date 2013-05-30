require 'yaml'

module SlideShare
  class Configuration
    KEYS = [:api_key, :shared_secret]
    IVARS = KEYS.map { |k| "@#{k.to_s}".to_sym }

    attr_accessor :api_key, :shared_secret

    def initialize
      self.class::IVARS.each { |iv| instance_variable_set iv, nil }
    end

    def load_from file
      config = YAML.load(open(file))
      self.class::KEYS.each_with_index { |k,i| instance_variable_set(IVARS[i], config[k.to_s]) }
    end

    def valid?
      self.class::IVARS.all? { |iv| !! instance_variable_get(iv) }
    end
  end
end
