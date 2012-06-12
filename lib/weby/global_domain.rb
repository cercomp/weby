module Weby
  class GlobalDomain
    
    def self.matches?(request)
      return !Weby::Subdomain.matches?(request)
    end
    
  end
end