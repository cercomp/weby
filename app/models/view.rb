class View < ApplicationRecord
  belongs_to :site
  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true

  def self.count_metrics(filter_kind, filter)
    filter_site = { site_id: site_id } if site_id.present?
    counts = {}
    case metric.to_sym
      when :views
        counts = where(filter_kind).where(filter_site).group(filter).count
      when :visitors
        where(filter_kind).where(filter_site).group(filter).group('session_hash').count.each_key do |key|
          counts[key[0]] = counts[key[0]].to_i + 1
        end
      when :uniq_visitors
        where(filter_kind).where(filter_site).group(filter).group('ip_address').count.each_key do |key|
          counts[key[0]] = counts[key[0]].to_i + 1
        end
    end
  end

  def self.daily_stats(year, month, metric, site_id = nil)
    filter_month = ['extract(month from created_at) = ?', month]
    count_metrics(filter_month, 'date(created_at)')

    finish_year, finish_month = month.to_i == 12 ? [year.to_i + 1, 1] : [year.to_i, month.to_i + 1]

    (Date.new(year.to_i, month.to_i)..Date.new(finish_year, finish_month) - 1.days)
      .map { |day| { date: day.strftime('%Y-%m-%d'), views: counts[day].to_i } }.to_json
  end

  def self.monthly_stats(year, metric, site_id = nil)
    filter_year = ['extract(year from created_at) = ?', year]
    count_metrics(filter_year, 'extract(month from created_at)')
    (1..12).map { |month| { month: month, views: counts[month.to_f].to_i } }.to_json
  end
end
