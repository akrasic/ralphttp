#!/usr/bin/env ruby
# rubocop:disable MethodLength

module Ralphttp

  # Public;  Get benchmarking information for a HTTP server
  class Wreckit < Ralphttp::Fixit
  attr_accessor :domain
  attr_accessor :hammer
  attr_accessor :ua

  # Public: Start the class and assign the domain anem to start
  #
  # options - Hash containing URL and number of concurrent/total connections
  #
  # Example:
  #     options = { url: 'http://domain.tld',
  #                 concurrent: 10,
  #                 total: 100
  #                 }
  #     pwong = Ralphttp::Wreckit.new(options)
  #
  # Returns Nil
  def initialize(options)
    super(options)
    @domain = options[:url]
    @ua = options[:useragent]
    @hammer = { :concurrent =>  options[:concurrent],
                :total => options[:requests] }
    @bucket = {}
  end

  # Public: Worker method, builds threads for querying the server
  #
  # Returns nil
  def blast
    begin
      arr = []
      start = Time.now
      loopy = calculate_loops

      (1..loopy.to_i).each do |f|
        Thread.abort_on_exception = false
        (1..@hammer[:concurrent].to_i).each do |s|
          arr[s] = Thread.new do
            k = getpage
            Thread.current['response'] = k['response']
            Thread.current['time'] = k['time']
            Thread.current['date'] = k['date']
          end
        end

        arr.shift
        # Join the hands and go ahead
        arr.each do |t|
          t.join
          # puts "#{t['date']} :: #{t['response']} :: #{t['time']} ms"
        end

      # End initial loop
      end
      @total_time = sprintf('%.2f', (Time.now - start))
    rescue ThreadError => e
      puts "Ralphttp::Wreckit error: #{e}"
    rescue SocketError => e
      puts "#{e} - Domain not found"
      exit
    end
  end

  private

  # Private: Calculate number of loops based on total number of connections
  # opposed to the total number of concurrent connections
  #
  #

  def calculate_loops
    @hammer[:total].to_i / @hammer[:concurrent].to_i
  end

  # Private - Returns metrics for conntacting a page
  #
  # Returns Hash with response code and time (in ms)
  def getpage
    begin
      out = start_http
    rescue Errno::ECONNREFUSED
      puts 'Connection refused'
    end
    out
  end

  # Private: Opens the domain for testing and gathers the performance info
  #
  # Returns Hash with response code and time in ms
  def start_http
    out = {}
    if @ua.nil?
      user_agent = { 'User-Agent' => 'Ralphttp-Wreck' }
    else
      user_agent = { 'User-Agent' => @ua }
    end

    Net::HTTP.start(@domain.host, @domain.port) do |http|
      start_request = Time.now
      request = Net::HTTP::Get.new(@domain, user_agent)
      end_request = sprintf('%.4f', ((Time.now - start_request) * (10**6)))


      response = http.request request
      if response.code == '200'
        @http_ok << response.code
      else
        @http_failed << response.code
      end

      out['response'] = response.code
      out['time'] = end_request
      out['date'] = Time.now.to_i

      unless @bucket[Time.now.to_i].kind_of?(Array)
        @bucket[Time.now.to_i] = []
      end
      @bucket[Time.now.to_i] << [response.code, end_request]
    end
    out
  end

  end
end
