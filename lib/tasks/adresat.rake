#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из adresat"
  task(:adresat, [:file] => :environment) do |_, args|

    #TASK STARTS
    args.file ||= '/home/tea/RubymineProjects/nmir/public/import/first_test_adresat.xls'
    titles = {}
    list = []
    readed_rows = 0
    temp =[]


    workbook = Spreadsheet.open(args.file).worksheets
    workbook.each do |worksheet|
      titles.clear

      worksheet.each do |row|
        if row[0].match /РЕЗУЛЬТАТ/
          row.each_with_index do |column, index|
            titles[column] = index if column.present?
          end
          titles[:number] = titles.count
          titles[:comment] = titles.count
          next
        end
        next if row.count == 0 || row.compact.count == 0
        row.to_a.each { |column| temp << column if column.present? }
        readed_rows += 1
        if readed_rows == 2
          list << temp
          readed_rows = 0
          temp = []
        end

      end
    end

    ParserUtil.schedule(list) do |delay, row|
      AdresatWorker.perform(row.to_a, titles)
    end
    #print "list = \n"
    #print "#{list[1]}\n"
    #print "titles= #{titles}\n"
    #print "comment = #{list[1][titles[:comment]]}"
    #print "\n\n#{list}\n"
  end
end