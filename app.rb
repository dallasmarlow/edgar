require 'sinatra/base'
require 'json'
require './lib/edgar'

module Edgar
  class App < Sinatra::Base

    helpers do

      def intervals interval
        case interval.to_sym
        when :seconds
          1
        when :minutes
          60
        when :hours
          3600
        when :days
          86400
        when :weeks
          604800
        when :months
          7257600
        end
      end

      def index_to_date index, interval = :seconds
        Time.now + ((index + 1) * intervals(interval))
      end

      def normalize_options params
        unless ['data', 'interval', 'frequency'].all? {|key| params.include? key}
          raise 'missing required fields for forecast'
        end

        options = {
          :interval  => intervals(params['interval']),
          :frequency => params['frequency'].to_i,
        }

        unless params['sample_method'] == 'none'
          options[:sample] = [params['sample_points'].to_i, params['sample_method'].to_sym]
        end

        unless params['horizon'].empty?
          options[:horizon] = params['horizon'].to_i
        end

        unless params['threshold'].empty?
          options[:threshold] = params['threshold'].to_f
        end

        options
      end

    end

    get '/' do
      erb :index
    end

    post '/forecast' do
      content_type :json

      data    = JSON.parse params[:data][:tempfile].read
      options = normalize_options params

      Edgar::GroupForecast.new(data, options).forecast.to_json
    end

    post '/' do
      data    = JSON.parse params[:data][:tempfile].read
      options = normalize_options params

      @forecasts = Edgar::GroupForecast.new(data, options).forecast

      erb :forecast
    end

  end
end