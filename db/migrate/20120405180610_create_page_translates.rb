class CreatePageTranslates < ActiveRecord::Migration
  def up
    Page.create_translation_table!({
      title: :string,
      summary: :text,
      text: :text
    },{
      migrate_data: true
    })
  end

  def down
    Page.drop_translation_table! migrate_data: true
  end
end
