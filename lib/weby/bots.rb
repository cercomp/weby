module Weby
  module Bots
    def self.read_xml
      uri = 'http://www.user-agents.org/allagents.xml'
      source = open(uri).read
      doc = Hash.from_xml(source)
      text = ''
      doc['user_agents']['user_agent'].each do |user_agent|
        text << "#{user_agent['String']}\n"
      end
      File.open('lib/weby/config/bots_list.txt', 'w') { |f| f.write(text) }
    end

    def self.load_list
      source = File.new('lib/weby/config/bots_list.txt').read
      @list = source.split("\n")
    end

    def self.is_a_bot?(name)
      load_list unless defined? @list
      return false if name.blank?
      %w(bot yahoo slurp google msn crawler).any? { |wc| name.downcase.include?(wc) } || @list.include?(name)
    end
  end
end
