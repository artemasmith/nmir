namespace :fias do
  class DbfWrapper
    require 'dbf'

    def table
      @table
    end

    def initialize file_path
      @table = DBF::Table.new(file_path)
    end

    #count = [:first|:all] conditions - hash of search params
    def find_objects(count = :all, conditions = {})
      if conditions.class == Hash && conditions
        result = @table.find(count, conditions)
      else
        raise "Wrong input params, must be hash of table's search values - #{ conditions }"
      end
      result
    end

    def find(count)
       @table.find(count)
    end

    def table_schema
      @table.schema
    end

    def create_local_table
      eval(table_schema) unless ActiveRecord::Base.connection.table_exists? table_name
    end

    def delete_local__table
      ActiveRecord::Migration.drop_table(table_name.to_sym)if ActiveRecord::Base.connection.table_exists? table_name
    end

    def eval_class
      eval("class DbfTable < ActiveRecord::Base; self.table_name = '#{table_name}'; end")
    end

    def table_name
      reg_exp = /create_table "(.+?)" do \|t\|/i
      if match = reg_exp.match(table_schema)
        return match[1]
      end
      return nil
    end

    def make_local_data(text)
      delete_local__table
      create_local_table
      eval_class
      DbfTable.reset_column_information
      record_count = @table.record_count
      current_record_count = 0
      slice_count = 3000
      summ_count = record_count / slice_count
      index = 0
      @table.each_slice(slice_count) do |records|
        time = Time.now
        DbfTable.transaction do
          records.each do |record|
            dbf_table = DbfTable.new
            record.attributes.each do |k|
              dbf_table.send("#{k[0].to_s.downcase}=", k[1])
            end
            current_record_count += 1
            dbf_table.save
          end
        end
        time_for_slice = Time.now - time
        index += 1
        seconds = (summ_count - index) * time_for_slice.to_i
        days = seconds / 86400
        hours = seconds / 3600
        minutes = (seconds - (hours * 3600)) / 60
        seconds = (seconds - (hours * 3600) - (minutes * 60))
        puts "#{text}:#{current_record_count}/#{record_count}/Time remain:#{days}:#{hours}:#{minutes}:#{seconds}"
      end
      self
    end
  end
end