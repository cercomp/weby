class RemoveColumns < ActiveRecord::Migration
  def self.up
		
		#Remove Inuteis
		 remove_column :pages, :editor_id
		 remove_column :pages, :editor_chief_id
		 remove_column :pages, :pdf

		 #Altera tipo do resumo
		 remove_column :pages, :summary
     add_column :pages, :summary, :text




	end

  def self.down
  
  	  add_column :pages, :editor_id, :integer
  	  add_column :pages, :editor_chief_id, :integer
	 	  add_column :pages, :pdf, :string

			remove_column :pages, :summary
			add_column :pages, :summary, :string
	
	end
end
