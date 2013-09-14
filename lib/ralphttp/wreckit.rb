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
    arr = []
    start = Time.now
    num_loops = calculate_loops

    (1..num_loops.to_i).each do |f|
      Thread.abort_on_exception = false
      (1..@hammer[:concurrent].to_i).each do |s|
        arr[s] = Thread.new do
          start_http
        end
      end

      arr.shift
      arr.each do |t|
        t.join
      end
    end
    @total_time = sprintf('%.2f', (Time.now - start))
    @bucket.keys.sort
  end

    private

  # Private: Calculate number of loops based on total number of connections
  # opposed to the total number of concurrent connections
  #
  def calculate_loops
    @hammer[:total].to_i / @hammer[:concurrent].to_i
  end

  # Private: Opens the domain for testing and gathers the performance info
  #
  # Returns Hash with response code and time in ms
  def start_http
    begin
      Net::HTTP.start(@domain.host, @domain.port) do |http|
        start_request = Time.now
        request = Net::HTTP::Get.new(@domain.request_uri)
        request.add_field('User-Agent', return_user_agent)
        end_request = sprintf('%.4f', ((Time.now - start_request) * (10**6)))

        response = http.request request
        http_status_counter(response.code)
        apply_processed_data([response.code, end_request])
      end
    rescue Errno::ECONNREFUSED
      @error << 'Connection refused'
    rescue Errno::ETIMEDOUT
      @error << 'Can not connect to the provided URL'
    rescue Net::ReadTimeout
      @error << 'ReadTimeout'
    rescue SocketError
      @error << 'Non resolvable domain!'
    end
  end

  # Private - Set the User Agent string for the Net::HTTP module
  #
  # Returns String User Agent
  def return_user_agent
    if @ua.nil?
      user_agent = { 'User-Agent' => 'Ralphttp-Wreck' }
    else
      user_agent = { 'User-Agent' => @ua }
    end
  end

  # Private - Fill @bucket with statistical data, the response code received
  # and the time that took to complete the HTTP request.
  #
  # droplet - Array holding the HTTP reponse code and HTTP request duration
  #
  # Returns nil
  def apply_processed_data(droplet)
      unless @bucket[Time.now.to_i].kind_of?(Array)
        @bucket[Time.now.to_i] = []
      end
      @bucket[Time.now.to_i] << droplet
  end

  # Private: Get number of HTTP status codes and their count
  #
  # code - Integer status code
  #
  # Returns nil
  def http_status_counter(code)
    if @status[code].nil?
      @status[code] = 0
    end

    @status[code] = (@status[code].to_i + 1)
  end
  end
end
