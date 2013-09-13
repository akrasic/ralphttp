module Ralphttp
  # Public: Format data for a reasonable output
  class Fixit
    attr_accessor :detailed
    attr_accessor :csv
    attr_accessor :bucket
    attr_accessor :total_time
    attr_accessor :status

    # Public: Start the class based on selected options
    #
    # options - Hash containing settings
    #
    # Returns nil
    def initialize(options)
      @status = {}
      @detailed = options[:detail]
      @csv = options[:csv] unless options[:csv].nil?
    end


    # Public: Output the header information
    #
    # Returns nil
    def print_header
      unless @detailed.nil?
        puts '%-30s %-10s %-10s' % ['Time', 'Req/s', 'Avg resp (ms)']
      end
    end
    # Public: Analyze collected data and show reasonable output
    #
    # Return Text output
    def analyze
      @bucket.keys.sort

      req = []
      ms = []

      unless @csv.nil?
        csv_header = ['Time', 'Req/s', 'Avg. resp. (ms)']
        csv = Ralphttp::CsvExport.new(csv_header)
      end

      print_header
      @bucket.map do |x, y|
        reqs = y.length
        req << reqs
        date = Time.at(x)
        ms = calc_response(y)

        csv.add_row([date, reqs, ms]) unless @csv.nil?

        puts sprintf('%-30s %-10s %-20s',
                     date, reqs, ms) unless @detailed.nil?
      end
      reqs_per_sec = sprintf('%.2f', (req.inject(:+).to_f / req.length.to_f))

      puts "\nRequests per second: #{reqs_per_sec}"
      @status.map { |x, y| puts "HTTP Status #{x}: #{y}" }
      puts "Total time: #{@total_time} s"

      csv.write(@csv)

    end

    private

    # Private: Calculate average response time in ms
    #
    # resp - Array
    #
    # Returns Float of average ms
    def calc_response(resp)
      r = []

      resp.each do |re|
        r << re[1]
      end
      sprintf('%.2f', (r.inject(:+).to_f / r.length.to_f))
    end

  end # EOC
end
