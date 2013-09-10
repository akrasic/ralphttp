module Ralphttp
  #
  # Loading class
  class Starter
    PROTOCOLS = %w(http https)
    attr_accessor :params

    # Public - Initialize the start with new
    def start
      options = arguments

      if options[:url].nil? || options[:concurrent].nil? ||
        options[:requests].nil?
        puts @params
        exit
      end

      wreckit = Ralphttp::Wreckit.new(options)
      wreckit.blast
      wreckit.analyze
    end

    # Public - Parse arguments for the script
    #
    # Returns Hash of arguments
    def arguments
      options = {}

      begin
        params = OptionParser.new do |opts|
          opts.banner = 'Usage: ralphttp [OPTIONS]'

          opts.on('-c', '--concurrent NUM',
                  'Number of concurrent connections')do |concurrent|
            options[:concurrent] = concurrent
          end

          opts.on('-n', '--requests NUM',
                  'Total number of requests to use') do |reqs|
            options[:requests] = reqs
          end

          opts.on('-u', '--url URL', 'URL of the page to benchmark') do |url|
            options[:url] = url
          end

          opts.on('-a', '--user-agent STRING', 'User Agent to use') do |ua|
            options[:useragent] = ua
          end

          opts.on('-d', '--detail', 'Show detailed report') do |d|
            options[:detail] = d
          end

          opts.on('-s', '--csv FILE', 'Output CSV data into file') do |c|
            options[:csv] = c
          end

          opts.on('-h', '--help', 'Show help') do
            puts opts
            exit
          end
        end
        params.parse!
        options[:url] = url_parse(options[:url]) unless options[:url].nil?
        @params = params
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
       puts params
       exit
      end # End begin

      options
    end

    private

    # Private - Checks and corrects the entered URL to proper syntax
    #
    # Returns String Parsed URL
    def url_parse(url)
      begin
        uri = URI.parse(url)

        uri = URI.parse("http://#{url}") if uri.class == URI::Generic
        uri.path = '/' unless uri.path.match(/^\//)

        uri if PROTOCOLS.include?(uri.scheme)
      rescue URI::InvalidURIError
        puts "Bad URL: #{url}"
      end

    end
  end # EOC
end # EOM
