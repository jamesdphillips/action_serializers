# ReuseArraySerializer
#
#   In the interest of reducing dup & needless instantiations this
#   class reuses a given configured serializer.
#
# @note should be used with caution, any memoized or uncleared instance variables
#   could yield unexpected results
#
# @note only serializes the object and ignores any embedded associations
#
# @example
#   ReuseArraySerializer.new(@bananas, serializer: BananaSerializer, scope: @ted_danson).serialize
class ReuseArraySerializer

  # @param collection [Enumerable] collection of records or relation
  # @param options [Hash]
  # @option options [ActiveModel::Serializer] :serializer for serializing collection; required
  # @option options [Symbol] :root root key
  def initialize(collection, options = {})
    @json_key, @collection = options[:root], collection
    @serializer = options[:serializer].new(collection, options)
  end

  def serialize
    {
      @json_key => @collection.map do |record|
        @serializer.object = record
        @serializer.serializable_object
      end
    }
  end

  def as_json(options = {})
    serialize()
  end
end
