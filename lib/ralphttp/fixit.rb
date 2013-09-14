module Ralphttp
  # Public: Format data for a reasonable output
  class Fixit
    attr_accessor :detailed
    attr_accessor :csv
    attr_accessor :csvexport
    attr_accessor :bucket
    attr_accessor :total_time
    attr_accessor :status
    attr_accessor :error
    attr_accessor :req

    # Public: Start the class based on selected options
    #
    # options - Hash containing settings
    #
    # Returns nil
    def initialize(options)
      @status = {}
      @error = []
      @detailed = options[:detail]

      unless options[:csv].nil?
        @csv = options[:csv]
        assign_csv_report
      end
    end

    # Public: Analyze collected data and show reasonable output
    #
    # Return Text output
    def analyze
      if @error.empty?
        display_results
      else
        puts 'Errors encountered when connecting:'
        @error.each do |e|
          puts e
        end
      end
    end

    # Public - Displays the results of the parsed data
    #
    # Returns nil
    def display_results
      print_header
      print_detailed_report
      write_csv_report
      display_status
    end

    # Public: Output the header information
    #
    # Returns nil
    def print_header
      unless @detailed.nil?
        puts sprintf('%-30s %-10s %-10s', 'Time', 'Req/s', 'Avg resp (ms)')
      end
    end

    private

    # Private - Print the status banner
    #
    # Returns nil
    def display_status
      reqs_per_sec = sprintf('%.2f',
                             (@req.inject(:+).to_f / @req.length.to_f))

      puts "\nRequests per second: #{reqs_per_sec}"
      @status.map do |status_code, status_count|
        puts "HTTP Status #{status_code}: #{status_count}"
      end
      puts "Total time: #{@total_time} s"
    end

    #
    # Private - Assign Ralphttp::CsvExport class if report is asked for
    #
    # Returns nil
    def assign_csv_report
      unless @csv.nil?
        csv_header = ['Time', 'Req/s', 'Avg. resp. (ms)']
        @csvexport = Ralphttp::CsvExport.new(csv_header)
      end
    end

    # Private - Write down the CSV report
    #
    # Returns nil
    def write_csv_report
      unless @csv.nil?
        @csvexport.write(@csv)
      end
    end

    # Private - Prints out a detailed report, if asked for
    #
    # Returns Array containing summarized data
    def print_detailed_report
      @req = []
      @bucket.map do |time, data|
        reqs = data.length
        @req << reqs
        date = Time.at(time)
        ms = calc_response(data)

        @csvexport.add_row([date, reqs, ms]) unless @csv.nil?

        puts sprintf('%-30s %-10s %-20s',
                     date, reqs, ms) unless @detailed.nil?
      end
    end

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
