module Weby
  class GlobalDomain
    def self.matches?(request)
      !Weby::Subdomain.matches?(request)
    end
  end
end
