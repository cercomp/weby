module API
  class APIController < ApplicationController
    skip_before_action :verify_authenticity_token

    def root
      render json: {versions: [{v1: api_v1_url}]}, status: 200
    end

    def not_found name=nil, query=nil
      message = case name
                  when :channel
                    t('api.channels.not_found', name: query)
                  when :concert
                    t('api.transmissions.not_found')
                end
      render json: {error: t('api.not_found'), message: message}, status: 404
    end

    if Rails.env.production?
      rescue_from Exception, with: :render_500
    end

    protected

    def api_defaults
      {per_page: 25}
    end

    def render_500 exception
      render json: {error: "#{exception.class} #{exception.message}"}, status: 500
    end

    def build_meta object_or_collection
      meta = {}
      if object_or_collection.respond_to? :to_ary
        if object_or_collection.respond_to? :total_count
          total = object_or_collection.total_count
          page = params[:page].to_i
          meta[:total] = total
          meta[:next] = page + 1 if page * api_defaults[:per_page] < total
        else
          meta[:total] = object_or_collection.size
        end
      else
        #?
      end
      meta
    end
  end
end