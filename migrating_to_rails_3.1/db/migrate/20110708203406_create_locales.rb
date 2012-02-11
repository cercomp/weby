class CreateLocales < ActiveRecord::Migration
  class Locale < ActiveRecord::Base; end

  def self.up
    create_table :locales do |t|
      t.string :name
      t.string :flag

      t.timestamps
    end

    # Insere a primeira Locale no banco
    Locale.reset_column_information
    Locale.create({
      :name => 'pt-BR',
      :flag => 'Brazil.png'
    })
  end

  def self.down
    drop_table :locales
  end
end
