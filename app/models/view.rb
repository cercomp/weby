class View < ActiveRecord::Base
  belongs_to :site
  belongs_to :viewable, polymorphic: true
  belongs_to :user
  attr_accessible :ip_address, :query_string, :referer, :user_agent, :request_path, :session_hash, :viewable, :user

  def self.daily_stats year, month, metric, site_id=nil
    filter_month = ["extract(month from created_at) = ?", month]
    filter_site = {site_id: site_id} if site_id.present?

    counts = {}
    case metric.to_sym
    when :views
      counts = where(filter_month).where(filter_site).group("date(created_at)").count
    when :visitors
      where(filter_month).where(filter_site).group("date(created_at)").group("session_hash").count.each_key do |key|
        counts[key[0]] = counts[key[0]].to_i + 1
      end
    when :uniq_visitors
      where(filter_month).where(filter_site).group("date(created_at)").group("ip_address").count.each_key do |key|
        counts[key[0]] = counts[key[0]].to_i + 1
      end
    end

    finish_year, finish_month = month.to_i == 12 ? [year.to_i + 1, 1] : [year.to_i, month.to_i + 1]
    
    (Date.new(year.to_i, month.to_i)..Date.new(finish_year, finish_month)-1.days).
      map{|day| {date: day.strftime('%Y-%m-%d'), views: counts[day.strftime('%Y-%m-%d')].to_i} }.to_json
  end

  def self.monthly_stats year, metric, site_id=nil
    filter_year = ["extract(year from created_at) = ?", year]
    filter_site = {site_id: site_id} if site_id.present?

    counts = {}
    case metric.to_sym
    when :views
      counts = where(filter_year).where(filter_site).group("extract(month from created_at)").count
    when :visitors
      where(filter_year).where(filter_site).group("extract(month from created_at)").group("session_hash").count.each_key do |key|
        counts[key[0]] = counts[key[0]].to_i + 1
      end
    when :uniq_visitors
      where(filter_year).where(filter_site).group("extract(month from created_at)").group("ip_address").count.each_key do |key|
        counts[key[0]] = counts[key[0]].to_i + 1
      end
    end

    (1..12).map{ |month| {month: month, views: counts[month.to_s].to_i} }.to_json
  end

end
