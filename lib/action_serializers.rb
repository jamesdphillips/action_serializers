require "action_serializers/base"
require "action_serializers/configuration"
require "action_serializers/resource_configuration"
require "action_serializers/linked_resource_configuration"
require "action_serializers/reuse_array_serializer"
require "action_serializers/version"

module ActionSerializers

  # Gem configuration
  #
  # @example
  #   ActionSerializers.configure do |config|
  #     config.global_metadata = { api_version: "08-01-2014" }
  #     config.profile_url = "https://www.bobsburgers.local/profile.txt"
  #   end
  #

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
