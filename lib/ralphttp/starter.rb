module Ralphttp
  class Starter
    attr_accessor :params

    # Public - Initialize the start with new
    def start
      options = arguments

      if options[:url].nil? || options[:concurrent].nil? ||
        options[:requests].nil?
        puts options.inspect
      else
        wreckit = Ralphttp::Wreckit.new(options)
        wreckit.blast
      end
    end

    # Public - Parse arguments for the script
    #
    # Returns Hash of arguments
    def arguments
      options = {}

      begin
        params = OptionParser.new do |opts|
          opts.banner = "Usage: ralphttp [OPTIONS]"

          opts.on('-c', '--concurrent NUM', 'Number of concurrent connections')           do |concurrent|
            options[:concurrent] = concurrent
          end

          opts.on('-n', '--requests NUM', 'Total number of requests to use')           do |reqs|
            options[:requests] = reqs
          end

          opts.on('-u', '--url URL', 'URL of the page to benchmark') do |url|
            options[:url] = url
          end

          opts.on('-a', '--user-agent STRING', 'User Agent to use') do |ua|
            options[:useragent] = ua
          end

          opts.on('-s', '--csv', 'Output data as CSV format') do |csv|
            options[:csv] = csv
          end

          opts.on('-j', '--json', 'Output data as JSON format') do |json|
            options[:json] = json
          end

          opts.on('-h', '--help', 'Show help') do
            puts opts
            exit
          end
          #opts.parse!
        end
        params.parse!
        options[:url] = url_parse(options[:url])
        @params = params
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts "What2"
       puts params
       exit
      end # End begin

      options
    end

    private

    # Private - Checks and corrects the entered URL to proper syntax
    #
    # Returns String Parsed URL
    def url_parse( url )
      uri = URI.parse(url)

      uri = URI.parse("http://#{url}") if uri.class == URI::Generic
      uri.path = "/" unless uri.path.match /^\//

      if ['http', 'https'].include?(uri.scheme)
        uri
      else
        puts "Incorrect URL added - #{url}"
      end

    end
  end # EOC
end # EOM