require 'yaml'

module SlideShare
  class Configuration
    KEYS = [:api_key, :shared_secret]
    IVARS = KEYS.map { |k| "@#{k.to_s}".to_sym }

    attr_accessor :api_key, :shared_secret

    class << self
      attr_accessor :api_key_default
      attr_accessor :shared_secret_default
    end

    def initialize
      self.class::IVARS.each do |iv|
        class_iv = "#{iv}_default".to_sym
        if self.class.instance_variable_defined? class_iv
          instance_variable_set iv, self.class.instance_variable_get(class_iv)
        else
          instance_variable_set iv, nil
        end
      end
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
