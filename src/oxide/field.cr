require "./argument"
require "./event_stream"

module Oxide
  abstract class BaseField
    abstract def type : Oxide::Type
    abstract def description : String?
    abstract def deprecation_reason : String?
    abstract def arguments : Hash(String, Oxide::Argument)
  end

  class Field(I, O) < BaseField
    getter type : Oxide::Type
    getter description : String?
    getter deprecation_reason : String?
    getter arguments : Hash(String, Oxide::Argument)
    getter applied_directives : Array(AppliedDirective)

    @resolve : Proc(I, Resolution, O)

    def initialize(@type, @resolve : Proc(I, Resolution, O), @description = nil, @deprecation_reason = nil, @arguments = {} of String => Oxide::Argument, @applied_directives = [] of AppliedDirective)
    end

    def resolve(object, argument_values, context, resolution_info)
      if object.is_a?(I)
        execution = Resolution.new(
          arguments: argument_values,
          execution_context: context,
          resolution_info: resolution_info
        )

        @resolve.call(object.as(I), execution)
      else
        raise SchemaError.new("Expected object to be #{I} but received #{object.class}")
      end
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end

  # SubscriptionField is a special field type for GraphQL subscriptions.
  #
  # Unlike regular fields that return a single value, subscription fields return an EventStream
  # that yields values over time. This enables real-time, push-based data delivery to clients.
  #
  # ## Type Parameters
  # - `I`: Input object type (the parent object, typically Nil for root subscription fields)
  # - `E`: Event type produced by the subscribe function
  # - `O`: Output type returned by the resolve function
  #
  # ## How it works
  # 1. The `subscribe` proc is called once to create an EventStream
  # 2. For each event from the stream, the `resolve` proc is called to transform it
  # 3. The transformed value is sent to the client as part of a GraphQL Response
  #
  # ## Example
  # ```
  # Oxide::SubscriptionField.new(
  #   type: message_type,
  #   subscribe: ->(object : Nil, resolution : Oxide::Resolution) {
  #     Oxide::ChannelEventStream.new(message_channel)
  #   },
  #   resolve: ->(event : Message, resolution : Oxide::Resolution) {
  #     event  # Transform event to response
  #   }
  # )
  # ```
  #
  # See SUBSCRIPTIONS.md for comprehensive documentation.
  class SubscriptionField(I, E, O) < BaseField
    getter type : Oxide::Type
    getter description : String?
    getter deprecation_reason : String?
    getter arguments : Hash(String, Oxide::Argument)
    getter applied_directives : Array(AppliedDirective)

    @subscribe : Proc(I, Resolution, EventStream(E)) | Proc(I, Resolution, ArrayEventStream(E)) | Proc(I, Resolution, ChannelEventStream(E)) | Proc(I, Resolution, EmptyEventStream(E))
    @resolve : Proc(E, Resolution, O)

    def initialize(
      @type,
      subscribe : Proc(I, Resolution, EventStream(E)) | Proc(I, Resolution, ArrayEventStream(E)) | Proc(I, Resolution, ChannelEventStream(E)) | Proc(I, Resolution, EmptyEventStream(E)),
      @resolve : Proc(E, Resolution, O),
      @description = nil,
      @deprecation_reason = nil,
      @arguments = {} of String => Oxide::Argument,
      @applied_directives = [] of AppliedDirective
    )
      @subscribe = subscribe
    end

    def subscribe(object, argument_values, context, resolution_info) : EventStream(E)
      if object.is_a?(I)
        execution = Resolution.new(
          arguments: argument_values,
          execution_context: context,
          resolution_info: resolution_info
        )

        @subscribe.call(object.as(I), execution).as(EventStream(E))
      else
        raise SchemaError.new("Expected object to be #{I} but received #{object.class}")
      end
    end

    def resolve(event, argument_values, context, resolution_info)
      if event.is_a?(E)
        execution = Resolution.new(
          arguments: argument_values,
          execution_context: context,
          resolution_info: resolution_info
        )

        @resolve.call(event.as(E), execution)
      else
        raise SchemaError.new("Expected event to be #{E} but received #{event.class}")
      end
    end

    def deprecated?
      !deprecation_reason.nil?
    end
  end
end
