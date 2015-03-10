class CabinetCounter
  EXPIRE = 4.hours

  def self.total_adv_count(user_id)
    key = hash_cabinet_total_adv_count(user_id)
    value = $redis.get(key) rescue nil
    if value.nil?
      value = calc_adv_count(user_id, :all)
      $redis.setex(key, EXPIRE, value) rescue nil
    end
    return value.to_i
  end

  def self.active_adv_count(user_id)
    key = hash_cabinet_active_adv_count(user_id)
    value = $redis.get(key) rescue nil
    if value.nil?
      value = calc_adv_count(user_id, :active)
      $redis.setex(key, EXPIRE, value) rescue nil
    end
    return value.to_i
  end

  def self.expired_adv_count(user_id)
    key = hash_cabinet_expired_adv_count(user_id)
    value = $redis.get(key) rescue nil
    if value.nil?
      value = calc_adv_count(user_id, :expired)
      $redis.setex(key, EXPIRE, value) rescue nil
    end
    return value.to_i
  end

  def self.drop_adv_count(user_id)
    key = hash_cabinet_total_adv_count(user_id)
    $redis.del(key) rescue nil
    key = hash_cabinet_expired_adv_count(user_id)
    $redis.del(key) rescue nil
    key = hash_cabinet_active_adv_count(user_id)
    $redis.del(key) rescue nil
  end

  private

  def self.calc_adv_count(user_id, status = :all)
    with = {}
    options = {
        :conditions => {},
        :with => with,
        :classes => [Advertisement]
    }
    with[:user_id] = user_id

    with['status_type'] = AdvEnums::STATUSES.index(status) if status != :all

    return ThinkingSphinx.count('', options)
  end

  def self.hash_cabinet_total_adv_count(user_id)
    "hash_cabinet_total_adv_count:#{user_id}"
  end

  def self.hash_cabinet_expired_adv_count(user_id)
    "hash_cabinet_expired_adv_count:#{user_id}"
  end

  def self.hash_cabinet_active_adv_count(user_id)
    "hash_cabinet_active_adv_count:#{user_id}"
  end
end