# This migration comes from acts_as_taggable_on_engine (originally 2)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]; end
else
  class AddMissingUniqueIndices < ActiveRecord::Migration; end
end
AddMissingUniqueIndices.class_eval do
  def self.up
    unless index_exists?(ActsAsTaggableOn.tags_table, :name)
      add_index ActsAsTaggableOn.tags_table, :name, unique: true
    end
  
    if index_exists?(ActsAsTaggableOn.taggings_table, :tag_id)
      remove_index ActsAsTaggableOn.taggings_table, :tag_id
    end
  
    if index_exists?(ActsAsTaggableOn.taggings_table, name: 'taggings_idx')
      remove_index ActsAsTaggableOn.taggings_table, name: 'taggings_idx'
    end
  
    if index_exists?(ActsAsTaggableOn.taggings_table, name: 'taggings_taggable_context_idx')
      remove_index ActsAsTaggableOn.taggings_table, name: 'taggings_taggable_context_idx'
    end
  
    begin
      add_index ActsAsTaggableOn.taggings_table,
                [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
                unique: true, name: 'taggings_idx'
    rescue ArgumentError => e
    end
  end

  def self.down
    remove_index ActsAsTaggableOn.tags_table, :name if index_exists?(ActsAsTaggableOn.tags_table, :name)
    remove_index ActsAsTaggableOn.taggings_table, name: 'taggings_idx' if index_exists?(ActsAsTaggableOn.taggings_table, name: 'taggings_idx')
    
    unless index_exists?(ActsAsTaggableOn.taggings_table, :tag_id)
      add_index ActsAsTaggableOn.taggings_table, :tag_id
    end
    unless index_exists?(ActsAsTaggableOn.taggings_table, name: 'taggings_taggable_context_idx')
      add_index ActsAsTaggableOn.taggings_table, [:taggable_id, :taggable_type, :context], name: 'taggings_taggable_context_idx'
    end
  end
end
