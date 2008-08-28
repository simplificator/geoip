require File.dirname(__FILE__) + '/../test_helper'

class IpRangeTest < ActiveSupport::TestCase

  def test_convert_to_numerical()
    assert_equal(0, IpRange.convert_to_numerical('0.0.0.0'))
    assert_equal(0, IpRange.convert_to_numerical('000000000000'))
    assert_equal(16909060, IpRange.convert_to_numerical('1.2.3.4'), 'sample from data file')
    assert_equal(16909060, IpRange.convert_to_numerical('001002003004'), 'sample from data file')
    assert_equal(255 * 256**3 + 255 * 256**2 + 255 * 256**1 + 255 * 256**0, IpRange.convert_to_numerical('255255255255'))
  end
  
  def test_verify_and_to_array()
    converted = IpRange.verify_and_to_array('1.2.3.4')
    assert_equal(4, converted.size)
    assert_equal(1, converted[0])
    assert_equal(2, converted[1])
    assert_equal(3, converted[2])
    assert_equal(4, converted[3])
    
    assert_raises(RuntimeError) {IpRange.verify_and_to_array('256.1.1.1')}
    assert_raises(RuntimeError) {IpRange.verify_and_to_array('1.1.1.1.1')}
    assert_raises(RuntimeError) {IpRange.verify_and_to_array('25525525525')}
    assert_raises(RuntimeError) {IpRange.verify_and_to_array('2552552552552')}
    
    converted = IpRange.verify_and_to_array('123069255001')
    assert_equal(4, converted.size)
    assert_equal(123, converted[0])
    assert_equal(69, converted[1])
    assert_equal(255, converted[2])
    assert_equal(1, converted[3])
    
    converted = IpRange.verify_and_to_array('255255255255')
    assert_equal(4, converted.size)
    assert_equal(255, converted[0])
    assert_equal(255, converted[1])
    assert_equal(255, converted[2])
    assert_equal(255, converted[3])
    
  end
  
  
  def test_convert_epoch_to_datetime()
    assert_equal(DateTime.new(1970, 1, 1), IpRange.convert_epoch_to_datetime(0))
    assert_equal(DateTime.new(1970, 1, 1, 0, 0, 1), IpRange.convert_epoch_to_datetime(1))
    assert_equal(DateTime.new(1970, 1, 1, 0, 1, 0), IpRange.convert_epoch_to_datetime(60))
  end
end
