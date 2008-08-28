class CreateIpRanges < ActiveRecord::Migration
  TABLES = [:ip_ranges, :ip_range_imports]
  def self.up
    TABLES.each do |table_name|
      create_table table_name do |t|
        t.string(:country_code_3)
        t.string(:country_code_2)
        t.string(:country)
        t.decimal(:range_start, :precision => 10)
        t.decimal(:range_end, :precision => 10)
        t.string(:registry)
        t.date(:assigned_at)
      end
      add_index(table_name, :range_start)
      add_index(table_name, :range_end)
    end
  end

  def self.down
    TABLES.each {|table_name| drop_table(table_name)}
  end
end
