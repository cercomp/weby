module DateHelper
  def print_date_end(date, format = :short)
    return  t("infinite") if date.nil?
    return l(date, format: format)
  end

  #Recebe um objeto page ou banner e verifica se a data de publicação está expirada ou não 
  def publication_status(obj) 
    return raw toggle_field(obj, "publish") if obj.date_end_at.nil?
    return raw toggle_field(obj, "publish") if publish_date?(obj) 
    return t("expired") 
  end

  def publish_date?(obj)
    obj.date_begin_at <= Time.now and obj.date_end_at > Time.now
  end
end
