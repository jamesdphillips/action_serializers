module ActionSerializers
  class ResourceConfiguration

    def initialize(json_key, options = {})
      @options, @options[:root] = options, json_key

      @serializer = options.delete(:serializer)
      @serializer ||= "#{json_key.to_s.classify}Serializer".constantize

      @collection_serializer = options.delete(:collection_serializer)
      @collection_serializer ||= ActionSerializers.configuration.collection_serializer
    end

    def json_key
      @options[:root]
    end

    def build_serializer(record_or_collection, options = {})
      if record_or_collection.is_a?(Hash)
        { @options[:root] => record_or_collection }
      else
        options.merge!(@options)

        if record_or_collection.respond_to?(:to_ary)
          build_collection_serializer(record_or_collection, options)
        else
          build_record_serializer(record_or_collection, options)
        end
      end
    end

    private

    def build_collection_serializer(collection, options)
      options[:serializer] = @serializer
      @collection_serializer.new(collection, options)
    end

    def build_record_serializer(record, options)
      @serializer.new(record, options)
    end

  end
end
