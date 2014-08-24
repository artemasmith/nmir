#!/bin/env ruby
# encoding: utf-8
module Russian
  
  def locative(title)
    last_chars = title[-2, 2]

    case last_chars
      when /[бвгджзклмнпрсфхцчшщ]$/
        title + 'е'
      when /а$/
        title.gsub(/.$/, 'е')
      when /ое|ий|ый/
        title.gsub(/ое|ий|ый/, 'ом')
      when /ая/
        title.gsub(/ая/, 'ой')
      when /ь$/
        title.gsub(/ь$/, 'и')
      else
        title
    end
  end

end
