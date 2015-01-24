#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'




namespace :domowoi do
  desc "Импорт информации из донрио"

  task(:donrio, [:file, :user_id, :type_donrio] => :environment) do |t, args|

    class String
      def first(limit = 1)
        self.match(%r{^(.{0,#{limit}})})[1]
      end
    end

    def get_objekt_type_0(str)
      if str.mb_chars.downcase.include?('к')
        [:room,:Sale]
      else
        [:flat,:Sale]
      end
    end

    def get_objekt_type_1(str)
      if str.to_s.mb_chars.strip.downcase =~ /участок/i
        [:lot,:Sale]
      else
        [:house,:Sale]
      end
    end

    def get_flat_count_from_string(str)
      {
          :qty_room => str.to_i == 0 ? 1 : str.to_i,
          :guesting => str.mb_chars.downcase.include?('г')
      }
    end


    def get_address_from_string(str)
      ret_ = str.split(',').compact
      return [ret_[0], ret_[1]]
    end

    def get_et_from_string_0(str)
      et_ = str.split(/\/|\\/).map{|e| e.mb_chars.downcase.include?('ц') ? 1 : e.to_f}
      floor = et_[0] || 0
      all_floor = et_[1] || 0
      material_id = (/([а-я\.]+)+$/.match('ц/4к')||[])[1].mb_chars.downcase
      {
          :floor => floor,
          :all_floor => all_floor,
          :material_id => {'к' => 0, 'п' => 1, 'мон' => 2, 'Дерево' => 3, 'мон.к' => 2, 'мон.' => 2}[material_id] || 0
      }
    end

    def get_et_from_string_1(str)
      et_ = str.split(/\/|\\/)
      all_floor = et_[0] || 0
      material_id = et_.last
      {
          :all_floor => all_floor,
          :material_id => {'к' => 6, 'кирп' => 0, 'сам.к' => 0, 'Панель' => 1, 'Каркасно-монолитный' => 2, ' брус' => 3, 'Блочный' => 4, 'Несъёмная опалубка' => 5, 'кам.оштук' => 6}[material_id] || 0

      }
    end



    def get_pl_from_string_0(str)
      pl_ = str.split(/\/|\\|\s+/).map{|e| e.to_f}
      s_all = pl_[0] || 0
      s_room = pl_[1] || 0
      s_kitchen = pl_[2] || 0
      {
          :s_all => s_all,
          :s_room => s_room,
          :s_kitchen => s_kitchen
      }
    end

    def get_pl_from_string_1(str)
      pl_ = str.split(/\/|\\|\s+/).map{|e| e.to_f}
      s_all = pl_[0] || 0
      s_room = pl_[1] || 0
      s_kitchen = pl_[2] || 0
      {
          :s_all => s_all,
          :s_room => s_room,
          :s_kitchen => s_kitchen
      }
    end

    def get_pl_uc_from_string(str)
      lot_space = str.to_i || 0
      {
          :lot_space => str.mb_chars.downcase.include?('га') ? lot_space / 10.0 : lot_space
      }
    end

    def get_client_from_string(str, user)
      phones = []
      client = nil
      begin
        list = str.scan(/[A-Za-z_А-Яа-я]+|[\s0-9\(\)-]+/).map{|e| e.gsub(/[-+\(\)\s]/, '').strip}.delete_if{|e| e==''}.group_by{|e| e !~/^\d+$/}.tap{|t| t[true]= (t[true]||[]).join(' ')}.tap{|t| (t[false]||[]).map!{
            |e| (e.first =~ /\d/) && (e.length == 7) ? "+7863#{e}" : e
        }.map!{
            |e| (e.first =~ /\d/) && (e.length == 10) ? "+7#{e}" : e
        }}


        phones = list[false].map{|e| ClientPhone.clear_number(e.strip)}
        raise 'numbers not found' if phones.count.zero?
        @client_phones = []
        phones.each { |number|
          @client_phones << ClientPhone.where(:user_id => user.id).by_clear_number(number)
          @client_phones << ClientPhone.scoped(:joins => "LEFT JOIN users ON users.id = client_phones.user_id").where(['users.agency_id = ?', user.agency_id]).by_clear_number(number) if user.agency.present?
        }
        @client_phones.flatten!

        if @client_phones.first.present? && @client_phones.first.client.present?
          return [@client_phones.first.client, false]
        else
          client = Client.new
          client.user_id = user.id
          client.name = list[true].to_s.strip == '' ? 'нет имени' : list[true]
          client.description = str
          phones.each do |number|
            client_phone = client.client_phones.build(:number => number, :clear_number => ClientPhone.clear_number(number), :user => user)
            client_phone.save!
          end

          @event = client.events_on.build(:subject => user, :event_type => :create)
          @event.save!

          client.source = 'ДонРио'
          client.save!
          return [client, true]
        end
      rescue Exception => e
        print e.message
        print "Не смог распарсить:#{str}"
      end

      client = Client.new
      client.user_id = user.id
      client.name = 'Не смог распарсить'
      client.description = str
      client.send(:create_without_callbacks)
      @event = client.events_on.build(:subject => user, :event_type => :create)
      @event.save
      print "Не смог распарсить клиента http://www.domowoi.com/klienty/#{client.try(:id)}\n"
      return [client, true]
    end

    def is_in_rostov_obl(adress)
      in_rostov_obl = false
      adress_parent = adress
      while adress_parent
        begin in_rostov_obl = true; break end if adress_parent.id == 2
        adress_parent = adress_parent.parents.first
      end
      in_rostov_obl
    end

    def get_first_in_rostov(adresses)
      first_adress = nil
      adresses.each do |adress|
        begin first_adress = adress; break end if is_in_rostov_obl(adress)
      end
      first_adress
    end

    def get_smart_address(name)
      name = name.gsub(/[\.,]/, '').strip.mb_chars.upcase
      adresses = Adress
      adresses = adresses.where(['UPPER(name) LIKE (?)', "%#{name}%"]).all
      adress = get_first_in_rostov(adresses)

      if adress.present?
        if adress.children.present?
          child = adress.children.where(['UPPER(name) LIKE (?)', "#{name}%"]).first || Adress.where(['UPPER(name) LIKE (?)', "%#{name}%"]).first
          child || adress
        else
          adress
        end
      end
    end

    def get_adress_from_rostov(name)
      name = name.gsub(/[\.,]/, '').strip.mb_chars.upcase
      Adress.find(46).children.where(['UPPER(name) LIKE (?)', "%#{name}%"]).first
    end

    def get_adress_from_prigorod(sub_name)
      sub_name_list = sub_name.to_s.gsub(/(.{1,3}\.\s?)/, '').split(/[-,|\/\\]/)
      first = sub_name_list[0]
      first_hash = {'Левенцовка' => 'Ливенцовка',
                    'Левенцова'=> 'Ливенцовка',
      }
      second = sub_name_list[1].to_s.gsub(/[\.,]/, '').strip.mb_chars.upcase
      second_hash = {}
      first_adress = get_smart_address(first_hash.include?(first) ? first_hash[first] : first)
      second_adress = (first_adress.present? ? first_adress.children.where(['UPPER(name) LIKE (?)', "%#{second_hash.include?(second) ? second_hash[second] : second}%"]).first : nil) if second.present?
      second_adress || first_adress
    end



    def get_address(name, sub_name)
      name = name
      if (adress = ((name.to_s.strip.mb_chars.downcase == 'пригород') && get_adress_from_prigorod(sub_name)) || get_adress_from_rostov(name) || get_smart_address(name)).present?
        return [adress, true]
      else
        hash_list =
            {'?' => nil,
             'пригород' => nil,
             'Вонвед' => 'Военвед',
             'Лениа' => 'Ленина',
             '1 Ордж.' => '1-й Орджоникидзе',
             '2 Ордж.' => '2-й Орджоникидзе',
             'Пригород' => 'Ростов-на-Дону',
             '1 Ордж' => '1-й Орджоникидзе',
             '2 Ордж' => '2-й Орджоникидзе',
             'Рост. море' => 'Ростовское море',
             'Аксайскийр-н' => 'Аксайский р-н',
             'Обл' => 'Ростовская обл.',
             'Область' => 'Ростовская обл.',
             'Рост море' => 'Ростовское море',
             'Рост.море' => 'Ростовское море',
             'Ц ентр' => 'Центр',
             '1 Ордж.' => '1-й Орджоникидзе',
             '2 Ордж.' => '2-й Орджоникидзе',
             'Рост... море' => 'Ростовское море',
             'РИЖТ' => 'Ленина',
             'Рост. Море' => 'Ростовское море'
            }
        new_name = hash_list[name]
        if new_name.present? && (adress = get_adress_from_rostov(new_name) || get_smart_address(new_name)).present?
          return [adress, true]
        end
      end
      return [Adress.find(2), false]
    end

    def get_adress_line(adress)
      adress_line = []
      adress__naem_line = []
      new_adress = adress
      while new_adress
        adress_line << new_adress.id
        adress__naem_line << new_adress.name
        new_adress = new_adress.parents.first
      end
      adress_line.sort
    end




    def change_hash(hash, index, proc, type)
      array = hash[index]
      array[1] = proc
      array[2] = type
      hash[index] = array
      return hash
    end

    def init_default_hash_0(hash)
      hash.delete(0)
      hash = change_hash(hash, 1, proc{|o| {'price' => (o.to_i * 1000)}}, :body)
      hash = change_hash(hash, 2, proc{|o| get_flat_count_from_string(o)}, :body)
      hash.delete(3)
      hash.delete(4)
      hash = change_hash(hash, 5, proc{|o| get_et_from_string_0 o}, :body)
      hash = change_hash(hash, 6, proc{|o| get_pl_from_string_0 o}, :body)
      hash.delete(7)
      hash.delete(8)
      return hash
    end

    def init_default_hash_1(hash)
      hash.delete(0)
      hash = change_hash(hash, 1, proc{|o| {'price' => (o.to_i * 1000)}}, :body)
      hash = change_hash(hash, 2, proc{|o| get_pl_uc_from_string(o)}, :body)
      hash.delete(3)
      hash.delete(4)
      hash = change_hash(hash, 5, proc{|o| {'qty_bedroom' => o.to_i}}, :body)
      hash = change_hash(hash, 6, proc{|o| {'qty_bedroom' => o.to_i}}, :body)
      hash = change_hash(hash, 7, proc{|o| get_pl_from_string_1 o}, :body)
      hash.delete(8)
      hash.delete(9)
      return hash
    end


    args.with_defaults(:file => '/home/tea/Downloads/донрио дома уч041213 (5).xls')
    args.with_defaults(:user_id => '1')
    args.with_defaults(:type_donrio => '1')
    user = User.find(args.user_id)
    workbook = Spreadsheet.open(args.file).worksheets
    new_objekt_count = 0
    old_objekt_count = 0
    skip_objekt_count = 0
    workbook.each do |worksheet|
      is_title = :title
      type_of_objekt = nil
      full_hash = {}
      index_col = 0
      model_hash = {}

      worksheet.each do |row|
        next if row.count == 0 || row.compact.count == 0
        begin
          is_title = :no_title
          model_hash.clear
          row.each_with_index do |col, index|
            model_hash[index] = [col.to_s, nil, nil]
#index =>? [русское название столбца, функция обработки, object?]
          end
          model_hash = init_default_hash_0 model_hash if args.type_donrio.to_i == 0
          model_hash = init_default_hash_1 model_hash if args.type_donrio.to_i == 1
          next
        end if is_title == :title

        if is_title == :no_title

          row.each do |col|
            full_hash.merge!({index_col => col.to_s})
            index_col += 1
          end

          type_of_objekt = get_objekt_type_0 full_hash[2] if args.type_donrio.to_i == 0
          type_of_objekt = get_objekt_type_1 full_hash[7] if args.type_donrio.to_i == 1
          model_hash.to_a.sort{|a,b| a[0] <=> b[0]}.each do |element|
            raise "ошибка типа записи для ключа '#{element[1][0]}' для #{type_of_objekt[0].to_s} с индексом #{element[0]}" if element[1][1].nil?
          end


          if args.type_donrio.to_i == 0
            client_array = get_client_from_string(full_hash[8], user)
          end

          if args.type_donrio.to_i == 1
            client_array = get_client_from_string(full_hash[9], user)
          end
          street_array = get_address_from_string(full_hash[4])
          address_id = get_address(full_hash[3], full_hash[4])[0].try(:id)

          deal_id = Objekt::Deal.index(type_of_objekt[1].to_s)
          objekt = nil
          body = nil
          is_new_objekt = true
          if client_array[1] || client_array[0].blank? #new client
            objekt= Objekt.new
            body = type_of_objekt[0].to_s.camelize.constantize.new
            is_new_objekt = true
          else #old client
            objekt_ids = []
            objekt_ids << Objekt.where(:user_id => user.id).all
            objekt_ids << Objekt.scoped(:joins => 'LEFT JOIN users ON users.id = objekts.user_id').where(['users.agency_id = ?', user.agency_id]).all if user.agency.present?
            ids = objekt_ids.flatten.map{|e| e.id}.uniq
            objekts = Objekt
            objekts = objekts.where(:id => ids) if ids.present?
            objekts = objekts.where(:deal_id => deal_id) if deal_id.present?
            body_element = full_hash
            class << self
              %w(qty_room floor all_floor s_all all_floor lot_space).each do |meth|
                define_method(meth) do |model_hash, body_element|
                  ret_val = nil
                  model_hash.each_pair do |key, value|
                    value[1].call(body_element[key]).each_pair do |setter, param|
                      if setter.to_s == meth
                        ret_val = param
                        break
                      end
                    end
                    break if ret_val.present?
                  end
                  return ret_val
                end
              end
            end
            if type_of_objekt[0] == :room
              qty_room = qty_room(model_hash, body_element)
              floor = floor(model_hash, body_element)
              all_floor = all_floor(model_hash, body_element)
              s_all = s_all(model_hash, body_element)
              table_name = 'rooms'
              class_name = 'Room'
              objekts = objekts.scoped(:joins=>%{
INNER JOIN "#{table_name}" ON "#{table_name}".id = objekts.body_id
AND objekts.body_type = '#{class_name}' })
              objekts = objekts.where("(rooms.qty_room is NULL) OR (rooms.qty_room = 0) OR (rooms.qty_room = #{qty_room})") if qty_room.present?
              objekts = objekts.where("(rooms.floor is NULL) OR (rooms.floor = 0) OR (rooms.floor = #{floor})") if floor.present?
              objekts = objekts.where("(rooms.all_floor is NULL) OR (rooms.all_floor = 0) OR (rooms.all_floor = #{all_floor})") if all_floor.present?
              objekts = objekts.where("(rooms.s_all is NULL) OR (rooms.s_all = 0) OR ((rooms.s_all > #{s_all.to_f*0.9}) AND (rooms.s_all < #{s_all.to_f*1.1}))") if s_all.present?
            end

            if type_of_objekt[0] == :flat
              qty_room = qty_room(model_hash, body_element)
              floor = floor(model_hash, body_element)
              all_floor = all_floor(model_hash, body_element)
              s_all = s_all(model_hash, body_element)
              table_name = 'flats'
              class_name = 'Flat'
              objekts = objekts.scoped(:joins=>%{
INNER JOIN "#{table_name}" ON "#{table_name}".id = objekts.body_id
AND objekts.body_type = '#{class_name}' })
              objekts = objekts.where("(flats.qty_room is NULL) OR (flats.qty_room = 0) OR (flats.qty_room = #{qty_room})") if qty_room.present?
              objekts = objekts.where("(flats.floor is NULL) OR (flats.floor = 0) OR (flats.floor = #{floor})") if floor.present?
              objekts = objekts.where("(flats.all_floor is NULL) OR (flats.all_floor = 0) OR (flats.all_floor = #{all_floor})") if all_floor.present?
              objekts = objekts.where("(flats.s_all is NULL) OR (flats.s_all = 0) OR ((flats.s_all > #{s_all.to_f*0.9}) AND (flats.s_all < #{s_all.to_f*1.1}))") if s_all.present?
            end

            if type_of_objekt[0] == :house
              lot_space = lot_space(model_hash, body_element)
              s_all = s_all(model_hash, body_element)
              table_name = 'houses'
              class_name = 'House'
              objekts = objekts.scoped(:joins=>%{
INNER JOIN "#{table_name}" ON "#{table_name}".id = objekts.body_id
AND objekts.body_type = '#{class_name}' })
              objekts = objekts.where("(houses.s_all is NULL) OR (houses.s_all = 0) OR ((houses.s_all > #{s_all.to_f*0.9}) AND (houses.s_all < #{s_all.to_f*1.1}))") if s_all.present?
              objekts = objekts.where("(houses.lot_space is NULL) OR (houses.lot_space = 0) OR ((houses.lot_space > #{all_floor.to_f*0.9}) AND (houses.lot_space < #{all_floor.to_f*1.1}))") if all_floor.present?
            end

            if type_of_objekt[0] == :lot
              lot_space = lot_space(model_hash, body_element)
              table_name = 'lots'
              class_name = 'Lot'
              objekts = objekts.scoped(:joins=>%{
INNER JOIN "#{table_name}" ON "#{table_name}".id = objekts.body_id
AND objekts.body_type = '#{class_name}' })
              objekts = objekts.where("(lots.lot_space is NULL) OR (lots.lot_space = 0) OR ((lots.lot_space > #{all_floor.to_f*0.9}) AND (lots.lot_space < #{all_floor.to_f*1.1}))") if all_floor.present?
            end


            objekts = objekts.where(:client_id => client_array[0].id) if client_array[0].present?
            objekts = objekts.for_adresses([address_id]) if address_id.present?



            if objekts.first.present?
              objekt = objekts.first
              body = objekt.body || type_of_objekt[0].to_s.camelize.constantize.new
              is_new_objekt = false
              objekt.instance_variable_set('@readonly', false)
              body.instance_variable_set('@readonly', false)
            elsif address_id.present?
              objekt = Objekt.new
              body = type_of_objekt[0].to_s.camelize.constantize.new
              is_new_objekt = true
            end
          end


          if objekt.present? && ((objekt.body || body).class.to_s.downcase.to_sym == type_of_objekt[0])
            objekt.user_id = user.id if is_new_objekt
            objekt.client_id ||= client_array[0].id if is_new_objekt
            objekt.deal_id = Objekt::Deal.index(type_of_objekt[1].to_s) if is_new_objekt
            objekt.condition_id = 0

            objekt.street = street_array[0] if is_new_objekt
            objekt.n_house = street_array[1] if is_new_objekt

#if args.type_donrio.to_i == 0
# objekt.comments = "#{full_hash[7]} #{full_hash[3]}".first(999) if is_new_objekt
#end
#if args.type_donrio.to_i == 1
# objekt.comments = "#{full_hash[8]} #{full_hash[3]}".first(999) if is_new_objekt
#end

            objekt.expired = true if is_new_objekt

            adresses_status = get_address(full_hash[3], full_hash[4])
            objekt.adress_ids = get_adress_line(adresses_status[0])

            if is_new_objekt
              %w(flat registration qty_bathroom year basement fasade deep facility window_material light water gas sewage entrance road_type quality balcony height all_floor material ownership).each do |element|
                body.send("#{element}=", 0) if body.respond_to?(element)
              end

              if user.agency.present?
                objekt.access_to_client = user.agency.access_to_client
                objekt.client.access_to_client = user.agency.access_to_client
              end

              objekt.more3years = false
              objekt.access_id = 7
              body.commission_for_colleague = 3
              body.commission = 6
            end



            model_hash.each_pair do |key, value|
              value[1].call(full_hash[key]).each_pair do |setter, param|
                setter_ = "#{setter}="
                param_ = param
                if (value[2] == :objekt) then
                  begin
                    objekt.send(setter_, param_)
                  rescue Exception => e
                  end
                else
                  begin
                    body.send(setter_, param_)
                  rescue Exception => e
                  end
                end
              end
            end

            body.price_1m = begin case
                                    when type_of_objekt[0] == :flat then body.price / body.s_all
                                    when type_of_objekt[0] == :house then body.price / body.s_all
                                    else 0 end end rescue 0 if body.respond_to?(:price_1m)


            if is_new_objekt
              objekt.save!
              body.objekt = objekt
              body.send(:create_without_callbacks)
              new_objekt_count += 1
            else
              old_objekt_count += 1
            end


            objekt.body_id = body.id

            body.send(:update_without_callbacks)
            objekt.save!
            objekt.client.send(:update_without_callbacks)

            unless adresses_status[1]
              print "Не смог распарсить адрес http://www.domowoi.com/obyavleniya/#{objekt.try(:id)} для #{full_hash[3]} и #{full_hash[4]}\n"
            else
              print "Обработан объект http://www.domowoi.com/obyavleniya/#{objekt.try(:id)} для [#{full_hash[3]} и #{full_hash[4]}] как [#{objekt.adress(:only_two_nearest_locations => true, :can_see_detail_address => true)}]\n"
            end


          else
            skip_objekt_count += 1
          end
          index_col = 0
          full_hash.clear

        end
      end
    end
    puts "загружено новых:#{new_objekt_count}/обновлено:#{old_objekt_count}/пропущено:#{skip_objekt_count}"
  end
end