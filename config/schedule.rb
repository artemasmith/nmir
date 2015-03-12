every 1.day, :at => '0:00 am' do
  rake 'advertisement:status'
end

every 1.day, :at => '1:00 am' do
  rake 'sitemap:create'
end

every 1.day, :at => '2:00 am' do
  rake 'log:clear'
end


every 1.day do
  rake 'ts:index'
end

every 10.minutes do
  rake 'ts:in:delta'
end



