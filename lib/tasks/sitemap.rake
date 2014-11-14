namespace :sitemap do
  desc "create sitemap"
  task :create => :environment do
    host = 'http://multilisting.su'
    FileUtils.mkdir_p('../../shared') unless Dir.exists?('../../shared')
    FileUtils.mkdir_p('../../public/shared') unless Dir.exists?('../../public/shared')
    FileUtils.mkdir_p('../../shared/public/xml') unless Dir.exists?('../../shared/public/xml')

    index = 0
    Advertisement.active.find_in_batches(batch_size: 2000) do |group|
      index += 1
      doc =  Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
          group.each do |advertisement|
            xml.url do
              xml.loc "#{Rails.application.routes.url_helpers.advertisement_url(advertisement, host: host)}_#{advertisement.url}"
              xml.changefreq 'weekly'
              xml.priority 0.9
            end
          end
        end
      end
      File.open(Rails.root.join('tmp', "sitemap_advertisement#{index}.xml"), 'w'){|f| f.write doc.to_xml}
      FileUtils.cp "tmp/sitemap_advertisement#{index}.xml", '../../shared/public/xml/'
    end

    index = 0
    total_count = Section.not_empty.count
    Section.not_empty.find_in_batches(batch_size: 10000) do |group|
      index += 1
      doc =  Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
          group.each do |section|
            xml.url do
              if section.url != '/'
                xml.loc "#{host}#{section.url}"
                xml.changefreq 'weekly'
                xml.priority 0.9
              else
                xml.loc "#{Rails.application.routes.url_helpers.root_url(host: host)}"
                xml.changefreq 'daily'
                xml.priority 1.0
              end
            end
          end
        end
      end
      File.open(Rails.root.join('tmp',"sitemap_section#{index}.xml"), 'w'){|f| f.write doc.to_xml}
      FileUtils.cp "tmp/sitemap_section#{index}.xml", '../../shared/public/xml/'
    end
    #
    # main sitemap
    doc =  Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.sitemapindex(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
        Dir.glob('../../shared/public/xml/*xml').sort.reverse.each do |filename|
          if filename != '../../shared/public/xml/sitemap.xml'
            xml.sitemap do
              xml.loc "#{Rails.application.routes.url_helpers.root_url(host: host)}#{filename.split('/').last}"
              xml.lastmod Date.current.strftime '%Y-%m-%d'
            end
          end
        end
      end
    end

    File.open(Rails.root.join('tmp','sitemap.xml'), 'w'){|f| f.write doc.to_xml}
    FileUtils.cp "tmp/sitemap.xml", '../../shared/public/xml/'
  end
end
