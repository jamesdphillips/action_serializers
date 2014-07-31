module ActionSerializers

  # @example
  #   class Bananas::ShowSerializer < ActionSerializers::Base
  #     resource :bananas
  #     linked :brands
  #
  #     meta :nutritional_guide
  #
  #     private
  #
  #     def metadata_nutritional_guide
  #       { top: [ :candy, :ice_cream ] }
  #     end
  #   end
  class Base
    class << self
      def inherited(base)
        base._resource = _resource.try(:dup)
        base._linked = (_linked || []).dup
        base._meta = (_meta || {}).dup

        base._metadata_key = (_metadata_key || ActionSerializers.configuration.metadata_key)
        base._linked_key = (_linked_key || ActionSerializers.configuration.linked_key)
        base._links_key = (_links_key || ActionSerializers.configuration.links_key)
      end

      attr_accessor :_resource, :_linked, :_meta
      attr_accessor :_metadata_key, :_linked_key, :_links_key

      alias :metadata_key :_metadata_key=
      alias :linked_key :_linked_key=
      alias :links_key :_links_key=

      # Define the primary resource
      #
      #   Having multiple resources us not compatible with :jsonapi_org schema
      #
      # @param key [Symbol, Hash]
      # @param options [Hash]
      # @option options [Class] :serializer
      # @example
      #   resource :banana
      #   resource :ripe_bananas, BananaSerializer
      #   resource :rotten_bananas, serializer: BananaSerializer
      # @example
      #   class Bananas::ShowSerializer < ActionSerializers::Base
      #     resource :bananas
      #     meta :nutritional_guide, -> { { top: [:cake, :pie] } }
      #   end
      def resource(key, options = {})
        raise "You may only define one primary resource" if @_resource.present?

        options = options.is_a?(Hash) ? options : { serializer: options }
        @_resource = ResourceConfiguration.new(key, options)
      end

      # Define linked resources for compound documents
      #
      # @param args [Symbol] a key representing a resource
      # @param args [Symbol, Hash] a key followed by options
      # @option args [Class] :serializer For serializing resources in a collection
      # @option args [Class] :collection_serializer For serializing a collection
      # @example
      #   linked :apples
      #   linked :rotten_apples => { :serializer => AppleSerializer }
      #   linked :apples, rotten_apples: { serializer: AppleSerializer }
      #   linked apples: { each_serializer: ApplesSerializer }
      # @example
      #   class Bananas::ShowSerializer < ActionSerializers::Base
      #     resource :bananas
      #     linked :apples
      #   end
      def linked(*args)
        resources = args.extract_options!
        resources = args.inject(resources) { |memo, resource| memo[resource] = {}; memo }

        resources.each do |key, options|
          @_linked << LinkedResourceConfiguration.new(key, options)
        end
      end

      # @param key [Symbol]
      # @param lamdba [Lambda] optional; can be used instead of defining a method
      # @example
      #   meta :nutritional_guide # Should have corresponding metadata_nutritional_guide method
      #   meta :nutritional_guide, -> { ... }
      # @example
      #   class Bananas::ShowSerializer < ActionSerializers::Base
      #     resource :bananas
      #     meta :nutritional_guide
      #
      #     private
      #
      #     def metadata_nutritional_guide
      #       { top: [ :candy, :ice_cream ] }
      #     end
      #   end
      def meta(key, lambda = nil)
        lambda ||= -> { send("metadata_#{key}") }
        @_meta.merge!(key => lambda)
      end
    end

    # @param record [Object] serializable object
    # @param options [Hash]
    # @option options [Array, Symbol] :only only return the given keys
    # @option options [Array, Symbol] :except exclude the given keys
    def initialize(record, options = {})
      @linked, @metadata = {}, ActionSerializers.configuration.inherited_metadata
      @only = Array(options.delete(:only))
      @except = Array(options.delete(:except))
      @options = options

      # @todo support :key_format
      #   fetch configuration from activemodel::serializers (?)

      @resource_serializer = self.class._resource.build_serializer(record, options)

      @linked_serializers = self.class._linked.map do |configuration|
        linked_collection = @options[configuration.json_key]
        linked_collection ||= if record.respond_to?(:to_ary)
          record.map(&"#{configuration.json_key}".to_sym).uniq # @todo build relation
        else
          record.send("#{configuration.json_key}")
        end

        configuration.build_serializer(linked_collection, options)
      end

      @metadata = self.class._meta.inject(@metadata) do |memo, (key, proc)|
        memo[key] = proc.call; memo
      end
    end

    def serialize(options = {})
      result = @resource_serializer.as_json

      if @linked_serializers.present?
        linked = self.class._linked_key ? (result[self.class._linked_key] = {}) : result

        @linked_serializers.each do |serializer|
          linked.merge!(serializer.as_json)
        end
      end

      if metadata_key = self.class._metadata_key
        result.merge!(metadata_key => @metadata) if @metadata.present?
      else
        result.merge!(@metadata)
      end

      # result.reject! { |key, _| @except.include?(key) || !@only.include?(key) }
      result
    end

    def as_json(options = {})
      serialize(options)
    end

  end
end
