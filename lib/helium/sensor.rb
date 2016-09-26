module Helium
  class Sensor < Resource
    attr_reader :name, :mac, :ports, :last_seen

    def initialize(opts = {})
      super(opts)

      @name      = @params.dig('attributes', 'name')
      @mac       = @params.dig('meta', 'mac')
      @ports     = @params.dig('meta', 'ports')
      @last_seen = @params.dig('meta', 'last-seen')
    end

    def self.all_path
      "/sensor?include=label"
    end

    # NOTE: currently this just returns the ids of labels. Once core returns
    # all label info via includes=label, we can get rid of the
    # label_relationships stuff
    def labels
      labels_params = Array(@params.dig('relationships', 'label', 'data'))
      @labels ||= labels_params.map{ |label_params|
         Label.new(client: @client, params: label_params)
      }
    end

    def timeseries(opts = {})
      size        = opts.fetch(:size, 1000)
      port        = opts.fetch(:port, nil)
      start_time  = opts.fetch(:start_time, nil)
      end_time    = opts.fetch(:end_time, nil)
      aggtype     = opts.fetch(:aggtype, nil)
      aggsize     = opts.fetch(:aggsize, nil)

      @client.sensor_timeseries(self,
        size:       size,
        port:       port,
        start_time: start_time,
        end_time:   end_time,
        aggtype:    aggtype,
        aggsize:    aggsize
      )
    end

    # Creates a new timeseries data point for this sensor
    # @option opts [String] :port A port for the data point
    # @option opts [String] :value A value for the data point
    # @option opts [DateTime] :timestamp A timestamp for the data point
    # @return [DataPoint]
    def create_timeseries(opts = {})
      port      = opts.fetch(:port)
      value     = opts.fetch(:value)
      timestamp = opts.fetch(:timestamp)

      @client.sensor_create_timeseries(self,
        port:       port,
        value:      value,
        timestamp:  timestamp
      )
    end

    # @return [DateTime, nil] when the resource was last seen
    def last_seen
      return nil if @last_seen.nil?
      @_last_seen ||= DateTime.parse(@last_seen)
    end

    # TODO can probably generalize this a bit more
    def as_json
      super.merge({
        name: name,
        mac: mac,
        ports: ports,
        last_seen: last_seen,
        labels: labels
      })
    end
  end
end
