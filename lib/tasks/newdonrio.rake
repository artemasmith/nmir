#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из донрио"
  task(:donrio, [:file] => :environment) do |_, args|

    #TASK STARTS
    args.file ||= '/home/tea/RubymineProjects/nmir/public/import/first_test_donrio.xls'
    titles = {}
    list = []


    workbook = Spreadsheet.open(args.file).worksheets
    workbook.each do |worksheet|
      titles.clear

      worksheet.each do |row|
        if titles.empty?
          row.each_with_index do |column, index|
            titles[column] = index if column.present?
          end
          next
        end
        next if row.count == 0 || row.compact.count == 0
        list << row.to_a
      end
    end

    ParserUtil.schedule(list) do |delay, row|
      DonrioWorker.delay_for(delay, :retry => false).perform(row.to_a, titles)
    end
  end
end