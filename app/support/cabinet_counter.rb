class CabinetCounter
  EXPIRE = 25.minutes

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

  #Abuse

  def self.total_abuse_count(user_id)
    get_from_redis(user_id, 'hash_cabinet_total_abuse_count', 'calc_abuse_count', :total)
  end

  def self.considered_abuse_count(user_id)
    get_from_redis(user_id, 'hash_cabinet_considered_abuse_count', 'calc_abuse_count', :considered)
  end

  def self.waiting_abuse_count(user_id)
    get_from_redis(user_id, 'hash_cabinet_waiting_abuse_count', 'calc_abuse_count', :waiting)
  end

  private

  def self.get_from_redis(key, get_redis_key, count_value_by, status = nil)
    redis_key = self.send(get_redis_key, key)
    value = $redis.get(redis_key) rescue nil
    if value.nil?
      value = self.send(count_value_by, key, status)
      $redis.setex(redis_key, EXPIRE, value) rescue nil
    end
    return value.to_i
  end

  def self.calc_abuse_count(user_id, status = nil)
    cond = { user_id: user_id }
    case status
      when :considered then cond = "user_id = #{user_id} AND status > 0"
      when :waiting then cond[:status] = 0
    end
    Abuse.where(cond).count
  end


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
  #abuses
  def self.hash_cabinet_total_abuse_count(user_id)
    "hash_cabinet_total_abuse_count:#{user_id}"
  end

  def self.hash_cabinet_considered_abuse_count(user_id)
    "hash_cabinet_considered_abuse_count:#{user_id}"
  end

  def self.hash_cabinet_waiting_abuse_count(user_id)
    "hash_cabinet_waiting_abuse_count:#{user_id}"
  end
end