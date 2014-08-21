class ChangeRepositoryDescriptionToText < ActiveRecord::Migration
  def self.up
    change_table :repositories do |t|
      t.change :description, :text
    end
  end
  def self.down
    change_table :repositories do |t|
      t.change :repositories, :string
    end
  end
end
