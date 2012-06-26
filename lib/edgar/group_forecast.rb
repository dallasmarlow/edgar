require 'thread'

module Edgar
  class GroupForecast
    attr_reader :data, :options

    def initialize data, options
      Thread.abort_on_exception = true
      @data    = data
      @options = options

      enqueue
    end

    def queue
      @queue ||= Queue.new
    end

    def enqueue
      data.keys.each do |key|
        queue << key
      end
    end

    def threads
      @threads ||= []
    end

    def forecast
      forecasts = {}

      Defaults.group_forecast[:threads].times do
        threads << Thread.new do
          until queue.empty?
            key = queue.deq :asynchronously rescue nil

            if key
              forecasts[key] = Forecast.new(options.merge({:data => data[key], :key => key})).to_hash rescue :failed
            end
          end
        end
      end

      threads.each &:join
      forecasts
    end

  end
end