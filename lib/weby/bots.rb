module Weby
  module Bots

    def self.load_list
      uri = "http://www.user-agents.org/allagents.xml"

      source = open(uri).read
      doc = Hash.from_xml(source)

      @list = []
      doc["user_agents"]["user_agent"].each do |user_agent|
        @list << user_agent["String"]
      end
    end

    def self.is_a_bot? name
      load_list unless defined? @list
      return false if name.blank?
      ["bot","yahoo","slurp","google","msn","crawler"].any? { |wc| name.downcase.include?(wc) } || @list.include?(name)
    end

  end
end
