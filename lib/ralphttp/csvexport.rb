module Ralphttp
  class CsvExport
    attr_accessor :header
    attr_accessor :data

    # Public - Start the class and pass the header fields along with the data
    #
    # header - Array holding the header field values
    #
    # Example:
    #   csv = Ralphttp::CsvExport( %w(Time Latency Response) )
    # Returns nil
    def initialize(header = nil)
      @data = []
      add_header(header)
    end

    # Public - Print out the CSV data
    #
    # Example:
    #   csv = Ralphttp::CsvExport.new
    #   csv.add_header(%w(Title Name Location)
    #   csv.add_row(%(CEO Khan Nebula))
    #   csv.print
    #   # => Title,Name,Location
    #   # => CEO,Khan,Nebula
    #
    # Returns String list in CSV format
    def print
      @data.unshift(@header)

      @data.each do |d|
        puts d
      end
    end

    # Public - Write the parsed data to a specified file
    #
    # file - String File location
    #
    # Example:
    #   csv.write('/tmp/file.csv')
    #
    # Returns nil
    def write(file)
      storage = File.open(file, 'w')

      @data.each do |d|
        storage.write("#{d}\n")
      end
      storage.close
    end
    #
    # Public - Add header description for the CSV fields
    #
    # header - Array of field data
    #
    # Retuns nil
    def add_header(header)
      @header =  header.join(',') if header.kind_of?(Array)
    end

    # Public - Add a row to the data Array
    #
    # row - Array holding field values
    #
    # Returns nil
    def add_row(row)
      @data << row.join(',')  if row.kind_of?(Array)
    end

  end
end
