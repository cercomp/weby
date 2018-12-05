require 'jsonapi/include_directive'
require 'jsonapi/renderer/resources_processor'

module JSONAPI
  class Renderer
    class Document
      def initialize(params = {})
        @data    = params.fetch(:data,    :no_data)
        @errors  = params.fetch(:errors,  [])
        @meta    = params[:meta]
        @links   = params[:links] || {}
        @fields  = _symbolize_fields(params[:fields] || {})
        @jsonapi = params[:jsonapi]
        @include = JSONAPI::IncludeDirective.new(params[:include] || {})
      end

      def to_hash
        @hash ||= document_hash
      end
      alias to_h to_hash

      private

      def document_hash
        {}.tap do |hash|
          if @data != :no_data
            hash.merge!(data_hash)
          elsif @errors.any?
            hash.merge!(errors_hash)
          end
          hash[:links]   = @links    if @links.any?
          hash[:meta]    = @meta     unless @meta.nil?
          hash[:jsonapi] = @jsonapi  unless @jsonapi.nil?
        end
      end

      def data_hash
        primary, included =
          ResourcesProcessor.new(Array(@data), @include, @fields).process
        {}.tap do |hash|
          hash[:data]     = @data.respond_to?(:to_ary) ? primary : primary[0]
          hash[:included] = included if included.any?
        end
      end

      def errors_hash
        {}.tap do |hash|
          hash[:errors] = @errors.map(&:as_jsonapi)
        end
      end

      def _symbolize_fields(fields)
        fields.each_with_object({}) do |(k, v), h|
          h[k.to_sym] = v.map(&:to_sym)
        end
      end
    end
  end
end
