require 'time_series'

module Edgar
  class Forecast < TimeSeries
    attr_reader :model, :forecast, :box_test, :horizon 

    def initialize options
      super

      unless options[:initialize] == false
        set_model
      end
    end

    def set_model
      model  = options[:model] || Defaults.model

      @model = r.eval %Q[time_series_model <- #{statement(model, :time_series, options[:model_options])}]
    end

    def set_forecast
      set_model unless model

      @horizon  = options[:horizon] || options[:frequency]
      @forecast = r.eval %Q[time_series_forecast <- #{statement(:forecast, :time_series_model, :h => horizon)}]
    end

    def model_sse
      set_model unless model

      r.eval(%q[time_series_model$SSE]).to_ruby
    end

    def fitted
      set_forecast unless forecast

      forecast.payload['fitted'].to_ruby.to_a
    end

    def values
      set_forecast unless forecast
      
      forecast.payload['mean'].to_ruby.to_a 
    end

    def confidence_intervals
      set_forecast unless forecast

      forecast.payload['level'].to_ruby
    end

    def upper_prediction_intervals
      set_forecast unless forecast

      forecast.payload['upper'].to_ruby.to_a
    end

    def lower_prediction_intervals
      set_forecast unless forecast
        
      forecast.payload['lower'].to_ruby.to_a
    end

    def prediction_interval type, interval
      raise 'unsupported prediction interval type' unless [:upper, :lower].include? type
      raise 'unsupported prediction interval' unless [80, 95].include? interval

      case type
      when :upper
        case interval

        when 80
          upper_prediction_intervals.collect {|intervals| intervals.first}
        when 95
          upper_prediction_intervals.collect {|intervals| intervals.last}          
        end
      when :lower
        case interval
 
        when 80
          lower_prediction_intervals.collect {|intervals| intervals.first}
        when 95
          lower_prediction_intervals.collect {|intervals| intervals.last}
        end
      end
    end

    def x
      set_forecast unless forecast
        
      forecast.payload['x'].to_ruby
    end

    def residuals
      set_forecast unless forecast
        
      forecast.payload['residuals'].to_ruby.to_a
    end

    def set_box_test
      set_forecast unless forecast

      @box_test = r.eval statement 'Box.test', 
                                   'time_series_forecast$residuals',
                                   :lag  => 20,
                                   :type => Defaults.box_test
    end

    def p_value
      set_box_test unless box_test

      box_test.payload['p.value'].to_ruby
    end

    def threshold_indices threshold = nil
      threshold ||= options[:threshold]

      [values, prediction_interval(:upper, 80), prediction_interval(:upper,  95)].collect do |series|
        series.find_index {|value| value >= threshold}
      end
    end

    def index_to_time index
      [:start, :interval].each do |key|
        raise "unable to produce date from index without option - #{key}" unless options.include? key
      end

      time_series_end = Time.at(options[:start]) + ((time_series.payload.size - 1) * options[:interval])
      time_series_end + ((index + 1) * options[:interval]).to_i
    end

    def thresholds threshold = nil
      threshold ||= options[:threshold]

      threshold_indices.collect do |index|
        index_to_time index if index
      end
    end

    def to_hash
      response = {
        :p_value   => p_value,
        :values    => values,
        :plot      => plot(:time_series_forecast),
        :upper_80  => prediction_interval(:upper, 80),
        :lower_80  => prediction_interval(:lower, 80),
        :upper_95  => prediction_interval(:upper, 95),
        :lower_95  => prediction_interval(:lower, 95),
        :residuals => residuals,
        :fitted    => fitted, 
      }

      if options[:threshold]
        response[:thresholds] = threshold_indices
      end

      if options[:key]
        response[:key] = options[:key]
      end

      response
    end

  end
end