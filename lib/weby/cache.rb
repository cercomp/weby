module Weby
  class Cache
    def self.global
      @gitems ||= {}
    end

    def self.request
      @ritems ||= {}
    end
  end
end
