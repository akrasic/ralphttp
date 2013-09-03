module Ralphttp
  # Public - Format data for a reasonable output

  class Fixit
    attr_accessor :json
    attr_accessor :csv

    def initialize(options)
      @json = options[:json] unless options[:json].nil?
      @csv = options[:csv] unless options[:csv].nil?
    end
  end
end
