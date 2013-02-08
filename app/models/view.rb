class View < ActiveRecord::Base
  belongs_to :site
  belongs_to :viewable, polymorphic: true
  belongs_to :user
  attr_accessible :ip_address, :query_string, :referer, :user_agent, :request_path, :session_hash, :viewable, :user

  def self.parsed_json site_id=nil, period=[Time.now - 14.days, Time.now]
    ini_date, fin_date = period[0].to_date, period[1].to_date

    filter = {created_at: ini_date..fin_date + 1.day}
    filter[:site_id] = site_id if site_id.present?

    database = where(filter).group("date(created_at)").count

    dfomrat = '%Y-%m-%d'
    result = {}
    ini_date.upto fin_date do |date|
      result[date.strftime(dfomrat)] = database[date.strftime(dfomrat)].to_i
    end

    result.map{ |key, value| {date: key, views: value} }.to_json
  end

end
