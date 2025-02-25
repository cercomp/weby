# vendor/engines/calendar/app/models/calendar/event_site.rb
module Calendar
  class EventSite < Calendar::ApplicationRecord
    include HasCategories
    acts_as_multisite

    belongs_to :site
    belongs_to :event, class_name: "::Calendar::Event", foreign_key: :calendar_event_id

    scope :front, -> { where(front: true) }
    scope :available, -> { joins(:event).where('calendar_events.begin_at <= :time', time: Time.current) }

    private

    def validate_position
      self.position = last_front_position + 1 if self.position.nil?
    end

    def last_front_position
      @event_site = Calendar::EventSite.where(site: self.site_id).front
      @event_site.maximum(:position).to_i
    end
  end
end