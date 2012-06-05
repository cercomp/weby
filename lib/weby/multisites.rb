module Weby
  module Multisites
    def self.included(base)
      base.extend MultisiteInterface
    end

    module MultisiteInterface
      def acts_as_multisite
        self.class_eval do
          scope :from_subsites, proc{|site, own = false|
            where("site_id IN (#{((own ? [site] : [{id: 0}])+site.subsites).select{|s| !s.blank? }.map{|s|s[:id]}.join(',')})").includes(:owner)
          }

          scope :from_main_site, proc{|site, own = false|
            where("site_id IN (#{((own ? [site] : [{id: 0}])<<site.main_site).select{|s| !s.blank? }.map{|s|s[:id]}.join(',')})").includes(:owner)
          }
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Weby::Multisites)
