require 'rserve'
require 'defaults'

module Edgar
  class TimeSeries
    attr_reader :options, :time_series

    def initialize options
      @options = options
      load_libraries

      unless options[:initialize] == false
        raise 'option data must be an array of numerics' unless all_numeric?(options[:data])
        @options[:interval] = normalize_interval options[:interval]
        load_data
        set_time_series
      end
    end

    def r
      @r ||= Rserve::Connection.new Defaults.rserve_connection.merge(options[:connection] || {})
    end

    def load_libraries
      [Defaults.libraries, options[:libraries]].flatten.compact.each do |library|
        r.eval %Q[library('#{library}')]
      end
    end

    def sample points = nil, method = nil
      unless points
        points, method = *options[:sample]
      end

      raise 'invalid sample argument - points must be an integer' unless points.kind_of? Integer
      series = []

      options[:data].each_slice(points) do |period|
        unless points > period.size
          case method
          when nil, :mean
            series << mean(period)
          when :median
            series << median(period)
          when :min
            series << period.min
          when :max
            series << period.max
          else
            raise 'unknown sample method'
          end
        end
      end

      series
    end

    def sum data = nil
      data ||= options[:data]
      raise 'sum data must be an array of numerics' unless all_numeric? data

      data.reduce(:+)      
    end

    def mean data = nil
      data ||= options[:data]
      raise 'mean data must be an array of numerics' unless all_numeric? data

      sum(data) / data.size
    end

    def median data = nil
      data ||= options[:data]
      raise 'median data must be an array of numerics' unless all_numeric? data

      data.sort[data.size / 2]
    end

    def load_data data = nil
      data = case options[:sample]
      when nil
        options[:data]
      else
        sample
      end

      r.assign 'time_data', data
    end

    def set_time_series frequency = nil
      frequency ||= options[:frequency]

      @time_series = r.eval %Q[time_series <- ts(time_data, frequency = #{frequency})]
    end

    def set_time_series_decomposed
      r.eval %q[time_series_decomposed <- decompose(time_series)]
    end

    def decomposed
      set_time_series_decomposed

      r.eval 'time_series_decomposed'
    end

    def remove_time_series_component! component
      unless [:seasonal, :trend, :random].any? {|c| c == component.to_sym}
        raise "unable to remove invalid time series component - #{component}"
      end

      set_time_series_decomposed
      r.eval %Q[time_series <- time_series - time_series_decomposed$#{component}]
    end

    def smooth points
      r.eval %Q[time_series <- SMA(time_series, n = #{points})]
    end

    def plot object
      plot_date = Time.now.strftime Defaults.plots[:date_format]
      plot_id   = rand Defaults.plots[:id_range]
      plot_file = File.join Defaults.plots[:dir], 
                            Defaults.plots[:path],
                            [plot_date, plot_id, Defaults.plots[:format]].join('.')

      # open file
      r.eval statement Defaults.plots[:format], quote(plot_file)

      # plot
      r.eval statement :plot, object, Defaults.plots[:options]
      r.eval %q[dev.off()]

      plot_file.gsub Defaults.plots[:dir], ''
    end

    private

    def normalize_interval interval
      case interval
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
      else
        interval
      end
    end

    def all_numeric? members
      members.all? {|member| member.kind_of? Numeric}
    end

    def statement method, arguments, options = nil
      if options
        %Q[#{method}(#{arguments(arguments)}, #{method_options(options)})]
      else
        %Q[#{method}(#{arguments(arguments)})]
      end
    end

    def arguments *members
      members.join ', '
    end

    def method_options options
      options = options.collect do |option, value|
        [option, value].join ' = '
      end

      arguments options
    end

    def quote value
      %Q['#{value}']
    end

  end
end