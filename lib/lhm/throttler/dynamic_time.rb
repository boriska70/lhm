require 'json'

module Lhm
  module Throttler
    class DynamicTime
      include Command

      DEFAULT_TIMEOUT = 2
      DEFAULT_STRIDE = 1000

      attr_accessor :filename
      attr_accessor :timeout_seconds
      attr_accessor :stride

      def initialize(stride, sleep, filename = '/tmp/lhm_dynamic_time.json')
        @stride = stride || DEFAULT_STRIDE
        @timeout_seconds = sleep || DEFAULT_TIMEOUT
        @filename = filename
        update_config
      end

      def execute
        update_config
        sleep timeout_seconds
      end

      def read_config_hash
        begin
          file = File.read(@filename)
          JSON.parse(file, symbolize_names: true)
        rescue Exception => e
          Lhm.logger.error "error reading file #{@filename}: #{e}"
          {}
        end.reverse_merge({delay: @timeout_seconds, stride: @stride})
      end

      def update_config
        config = read_config_hash
        new_timeout_seconds = config[:delay]
        new_stride = config[:stride]

        if new_timeout_seconds != timeout_seconds
          Lhm.logger.info "updating timeout_seconds from #{timeout_seconds || 'nil'} to #{new_timeout_seconds}"
          @timeout_seconds = new_timeout_seconds
        end

        if new_stride != stride
          Lhm.logger.info "updating stride from #{stride || 'nil'} to #{new_stride}"
          @stride = new_stride
        end
      end
    end
  end
end