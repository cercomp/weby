class CreatePageI18ns < ActiveRecord::Migration
  class Page < ActiveRecord::Base; end
  class PageI18n < ActiveRecord::Base; end

  def self.up
    create_table :page_i18ns do |t|
      t.references :page
      t.references :locale
      t.string :title
      t.text :summary
      t.text :text

      t.timestamps
    end

    say_with_time 'Updating page i18ns fields' do
      PageI18n.reset_column_information
      Page.all.each do |page|
        PageI18n.create({
          :page_id => page.id,
          :locale_id => 1,
          :title => page.title,
          :summary => page.summary,
          :text => page.text
        })
      end
    end

    remove_column :pages, :title
    remove_column :pages, :summary
    remove_column :pages, :text
  end

  def self.down
    add_column :pages, :title,    :string
    add_column :pages, :summary,  :text
    add_column :pages, :text,     :text

    Page.reset_column_information
    say_with_time 'Recovering Page fields' do
      PageI18n.all.each do |page_i18n|
        Page.find(page_i18n.page_id).update_attributes({
          :title => page_i18n.title,
          :summary => page_i18n.summary,
          :text => page_i18n.text
        })
      end
    end

    drop_table :page_i18ns
  end
end
