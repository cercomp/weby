module DateHelper
  def print_date_end(date, format = :short)
    return  t("infinite") if date.nil?
    return l(date, format: format)
  end

  #Recebe um objeto page ou banner e verifica se a data de publicação está expirada ou não 
  def publication_status(obj, options={})
    return raw toggle_field(obj, "publish", 'toggle_field', options) if obj.date_end_at.nil?
    return raw toggle_field(obj, "publish", 'toggle_field', options) if publish_date?(obj)
    return t("expired") 
  end

  def publish_date?(obj)
    obj.date_begin_at <= Time.now and obj.date_end_at > Time.now
  end

  def map_months_from_date end_date
    end_date ||= Time.now
    months, curr_date = [], Time.now
    while curr_date.beginning_of_month >= end_date.beginning_of_month
      months << [l(curr_date.to_date, format: :monthly), curr_date.strftime('%m/%Y')] #TODO use a block for cutsom format
      curr_date -= 1.month
    end
    [Time.now.year.downto(end_date.year).to_a, months]
  end
end
