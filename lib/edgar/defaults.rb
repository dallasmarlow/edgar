module Edgar
  module Defaults

    def self.libraries
      @libraries ||= [
        'forecast',
      ]
    end

    def self.model
      :ets
    end

    def self.group_forecast
      @group_forecast ||= {
        :threads => 20,
      }
    end

    def self.box_test
      @box_test ||= %q['Ljung-Box']
    end

    def self.rserve_connection
      @rserve_connection ||= {}
    end

    def self.plots
      @plots ||= {
        :dir      => File.join(File.dirname(__FILE__), '..', '..', 'public'),
        :path     => 'img/plot',
        :format   => :png,
        :id_range => (10 ** 8)..(10 ** 10),
        :date_format => '%Y%m%d-%H:%m',
        :options     => {:xaxt => %q['n']},
      }
    end

  end
end