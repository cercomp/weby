module HasCategories
  extend ActiveSupport::Concern

  included do
    acts_as_ordered_taggable_on :categories

    def category_list_before_type_cast
      category_list.to_s
    end

    def self.uniq_category_counts
      category_counts.each_with_object(Hash.new) do |j, hash|
        name = j.name.upcase
        if hash[name]
          hash[name].count += j.count
        else
          hash[name] = j
        end
        hash
      end.values
    end
  end
end
