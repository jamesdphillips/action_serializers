module ActionSerializers

  #
  # Serializer Configuration
  #
  # @!attribute [rw] metadata_key
  #   @return [Symbol] key describing metadata resources; if nil metadata is include in document root; defaults to meta
  # @!attribute [rw] linked_key
  #   @return [Symbol] key describing linked resources; if nil linked resources are included in document root; defaults to linked
  # @!attribute [rw] links_key
  #   @return [Symbol] key describing url templates; defaults to links
  # @!attribute [rw] global_metadata
  #   @return [Array] metadata every document should contain; empty by default
  # @!attribute [rw] profile_url
  #   @return [Array] used when extending jsonapi to describe changes
  #   @see http://jsonapi.org/extending/
  # @!attribute [rw] collection_serializer
  #   @return [Class] Default serializer to use when serializing collections; default ReuseArraySerializer
  #   @note ReuseArraySerializer is built for speed and may cause unexpected behaviour
  # @!attribute [rw]
  #
  # @see http://jsonapi.org/format/ json:api docs
  #
  class Configuration

    attr_accessor :metadata_key, :linked_key, :links_key
    attr_accessor :global_metadata, :profile_url
    attr_accessor :collection_serializer
    attr_accessor :include_embedded_associations

    def initialize
      @metadata_key = :meta
      @linked_key = :linked
      @links_key = :links

      @global_metadata = {}
      @profile_url = nil

      @collection_serializer = ReuseArraySerializer

      @include_embedded_associations = false
    end

    # @note resolved metadata including profile_url if applicable
    def inherited_metadata
      @inherited_metadata ||= global_metadata.merge((@profile_url && {profile: @profile_url}) || {})
    end

  end
end
