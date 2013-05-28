module Weby
  module Bots

    def self.read_xml
      uri = "http://www.user-agents.org/allagents.xml"

      source = open(uri).read
      File.open("lib/weby/bots_list.xml", 'w') {|f| f.write(source) }
    end

    def self.load_list
      source = File.new("lib/weby/bots_list.xml").read
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
