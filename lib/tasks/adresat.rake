#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из adresat"
  task(:adresat, [:file] => :environment) do |_, args|

    #TASK STARTS
    args.file ||= '/home/tea/RubymineProjects/nmir/public/import/first_test_adresat.xls'


    workbook = Spreadsheet.open(args.file).worksheets
    workbook.each do |worksheet|
      titles = {}
      list = []
      readed_rows = 0
      temp = []

      worksheet.each do |row|
        next if row.count == 0 || row.compact.count == 0

        if row[0].to_s.match /РЕЗУЛЬТАТ/i

          if titles.present? && list.present?
            schedule_import list, titles
          end

          titles.clear
          list.clear
          readed_rows = 0
          temp.clear

          row.each_with_index do |column, index|
            titles[column] = index if column.present?
          end
          titles[:number] = titles.count
          titles[:comment] = titles.count
          next
        end

        row.to_a.each { |column| temp << column if column.present? }
        readed_rows += 1
        if readed_rows == 2
          list << temp
          readed_rows = 0
          temp = []
        end
      end
      schedule_import list, titles
    end



  end

  def schedule_import list, titles
    ParserUtil.schedule(list) do |delay, row|
      AdresatWorker.delay_for(delay, :retry => false).perform(row.to_a, titles)
    end
  end
end