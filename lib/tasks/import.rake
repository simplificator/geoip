

namespace :geoip do
  COLUMN_NAMES = ['range_start', 'range_end', 'country_code_2', 'country_code_3', 'country', 'registry', 'assigned_at']
  BATCH_SIZE = 200
  DATABASE_DOWNLOAD_HOST = 'software77.net'
  DATABASE_DOWNLOAD_PATH = '/cgi-bin/ip-country/geo-ip.pl?action=downloadZ'
  
  desc('Import Data from CSV file')
  # Import the Data from CSV file in a temporary table
  # then rotate tables and cleanup
  #
  # Using a RDBMS seemed straight forward to me but perhaps is overkill and a binary tree
  # search through a packed/sorted file with the same data would be ok too...
  task :import  => [:environment] do
    file = create_import_filename()
    if File.exist?(file)
      ActiveRecord::Base.logger.info("Start of Import from file #{file}")
      batch = []

      IO.foreach(file) do |line|
        # next line if not content
        next if not line.start_with?('"')

        batch << import_line_to_array(line)
        # ready to import batch
        if batch.size == BATCH_SIZE
          IpRangeImport.import(COLUMN_NAMES, batch, :validate => false)
          batch = []
        end
        # Do not use create!, use batch import from ar-extensions gem
        # My tiny benchmark shows that this is about 6 times faster
      end
      # import last batch (if entries in data file is not a multiple of batch_size...almost everytime)
      IpRangeImport.import(COLUMN_NAMES, batch, :validate => false)
      # rotate tables and clean up import table
      rotate_tables()
    else
      ActiveRecord::Base.logger.info("Could not find file #{file}. No imports.")
    end
    
    ActiveRecord::Base.logger.info("Done with import from file #{file}")
  end
  
  
  
  desc('Download Data file from server')
  task :download  => [:environment] do
    zip_file = create_import_filename('zip')
    csv_file = create_import_filename('csv')
    File.unlink(csv_file) if File.exist?(csv_file)
    Net::HTTP.start(DATABASE_DOWNLOAD_HOST) do |http|
      resp = http.get(DATABASE_DOWNLOAD_PATH)
      open(zip_file, 'wb') do |file|
        file.write(resp.body)
      end
    end
    zf = Zip::ZipFile.open(zip_file)
    zf.each do |entry|
      # zip file with just one entry
      zf.extract(entry, csv_file)
    end
    File.unlink(zip_file)
    ActiveRecord::Base.logger.info("Download of Database file succeeded: #{File.exist?(csv_file)}")
    ActiveRecord::Base.logger.info("File size is: #{File.stat(csv_file).size / 1024} kb")
  end
  
  
  
  
  
  private 
  def create_import_filename(extension = 'csv')
    date = Date.today
    filename = "data_#{date.day}.#{date.month}.#{date.year}.#{extension}"
    File.join(RAILS_ROOT, 'db', 'data', filename)  
  end
  
  # rotate tables and empty import table
  def rotate_tables
    ActiveRecord::Base.logger.info("Imported. Now rotating tables.")
    # rotate tables
    ActiveRecord::Base.connection.execute(
      "RENAME TABLE #{IpRange.table_name} TO #{IpRange.table_name}_tmp, 
      #{IpRangeImport.table_name} TO #{IpRange.table_name},
      #{IpRange.table_name}_tmp TO #{IpRangeImport.table_name};")
    # remove imports, cleanup for next import
    IpRangeImport.delete_all
  end
  # convert a line from import file to array
  # order of columns is same as in COLUMN_NAMES
  def import_line_to_array(line) 
    # split line. for format see header of import file 
    range_start, range_end, registry, 
    assigned, two_digit, three_digit, country = line.delete!('"').split(',')

    # convert to integer / datetime
    range_start, range_end = range_start.to_i, range_end.to_i
    country = country.strip
    assigned_at = IpRange.convert_epoch_to_datetime(assigned.to_i)

    [range_start, range_end, two_digit, three_digit, country, registry, assigned_at]
  end
end
