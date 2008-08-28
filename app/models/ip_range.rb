class IpRange < ActiveRecord::Base
  # Factors used to convert an IP to its numerical representation
  FACTOR = [256**3, 256**2 , 256**1, 256**0]
  # Start of epoch (1.1. 1970). Used for conversions the Database file contains 
  # time in epoch seconds
  START_OF_EPOCH = DateTime.new(1970,1,1)
  
  #
  # Lookup an IP in the Database
  # Supported formats are described in IpRange.verify_and_to_array() method
  def self.lookup(ip)
    self.find(:first, :conditions => ['range_start <= :ip AND range_end >= :ip', 
        {:ip => convert_to_numerical(ip)}])
  end
  
  # Start of range as IP
  def start_ip
    IpRange.convert_to_ip(range_start)
  end
  # End of range as IP
  def end_ip
    IpRange.convert_to_ip(range_end)
  end
  # Number of hosts (available IPs) in the range
  def number_of_hosts()
    range_end - range_start
  end
  
  #
  # Verify and convert an IP. If format is not recognized then RuntimeError is thrown.
  # Valid formats
  # - A string of 12 numerical chars, representing 4 groups of 3 digits padded with 0(012123001066 -> 12.123.1.66)
  # - A string where each block is separated with dots (12.12.12.12)
  # The first representation is supported so we can use the ip in the URL string
  # without confusing ActionPack: geoip/089123123123.xml (the dots are confusing routings)
  def self.verify_and_to_array(ip)
    if (not ip.include?('.')) && ip.length == 12
      converted = ip.split('').in_groups_of(3).map() {|item| item.join.to_i}
    else
      converted = ip.split('.').map() {|item| item.to_i}
    end
    # must contain of 4 blocks and each block must be 0-255
    raise("IP #{ip} is not valid") if converted.size != 4
    converted.each() {|item| raise("Each block must be in range 0 - 255 but was #{item}") if (item < 0 || item > 255)}
    converted
  end
  
  # convert a IP to its numerical representation
  # Valid formats are described in verify_and_to_array()
  def self.convert_to_numerical(ip)
    parts = verify_and_to_array(ip)
    numerical = 0
    parts.each_with_index() do |item, index|
      numerical +=  item *  FACTOR[index]
    end
    numerical
  end
  
  def self.convert_to_ip(numerical)
    ip = ''
    FACTOR.each_with_index() do |factor, index|
      ip += '.' if index > 0
      ip += numerical.div(factor).modulo(256).to_s
    end
    ip
  end
  
  # convert number of seconds since start of the epoch (1.1. 1970) to datetime
  def self.convert_epoch_to_datetime(epoch)
    START_OF_EPOCH.dup.advance(:seconds => epoch)
  end
  
  # custom to_s method which displays start and end of range
  def to_s()
    "#{range_start} - #{range_end}"
  end
  
  def to_csv(separator = ',')
    country_code_2 + separator + country_code_3 + separator + country
  end
end