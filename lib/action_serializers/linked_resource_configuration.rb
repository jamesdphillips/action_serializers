module ActionSerializers
  class LinkedResourceConfiguration < ResourceConfiguration

    # @note Linked resources should always appear as a collection
    # @see http://jsonapi.org/format/#document-structure-compound-documents
    def build_record_serializer(record, options)
      build_collection_serializer([record], options)
    end

  end
end
