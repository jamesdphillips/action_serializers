module ActionController
  module ActionSerialization
    extend ActiveController::Serialization

    private

    def build_json_serializer(resource, options = {})
      serializer = options.fetch(:serializer, ActiveModel::Serializer.serializer_for(resource))
      action_serializer = serializer_for_action(params[:action])

      options = default_serializer_options.merge!(options).merge!(view_assigns)
      options[:scope] = serialization_scope unless options.has_key?(:scope)
      options[:resource_name] = controller_name if resource.respond_to?(:to_ary)

      if options[:serializer] || !action_serializer
        serializer.new(resource, options)
      elsif action_serializer
        action_serializer.new(resource, options)
      end
    end

    def serializer_for_action(action)
      class.name.gsub(/Controller$/, "::#{action.camelize}Serializer").safe_constantize
    end

  end
end
