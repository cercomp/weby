class AddEmailsColumnToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :emails, :text

    # Pega os emails dos usuários relacionado e agrupa no campo 'emails'
    con = ActiveRecord::Base.connection
    Group.all.each do |group|
      sql = "SELECT u.email FROM users AS u INNER JOIN groups_users AS gu ON u.id = gu.user_id WHERE gu.group_id = #{group.id}"
      group.emails = con.execute(sql).map{ |u| u['email'] }.join(', ')
      group.save!
    end

    # Remoção da tabela ficará para outro commit
    #drop_table :groups_users
  end

  def self.down
    remove_column :groups, :emails

    #create_table :groups_users, :id => false do |t|
    #  t.integer :group_id, :null => false
    #  t.integer :user_id, :null => false
    #end
  end
end
