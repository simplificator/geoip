#
# Extends IpRange so we have the same columns and can use different tables
# for import and live data
#
class IpRangeImport < IpRange
  set_table_name('ip_range_imports')
end