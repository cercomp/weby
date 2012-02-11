class CreatePaginas < ActiveRecord::Migration
  def self.up
    create_table :paginas do |t|

      #Atributos em comum
      t.date :dt_cadastro
      t.date :dt_publica
      t.date :dt_inicio
      t.date :dt_fim
      t.string :imagem
      t.string :posicao
      t.string :status
      t.integer :autor_id
      t.string :editor
      t.string :editor_chefe
      t.string :texto
      t.string :url
      t.integer :site_id

      #Atributos de Eventos e Notícias
      t.string :fonte
      t.string :titulo
      t.string :texto_imagem
      t.string :resumo
      t.string :pdf
      t.integer :capa
      t.datetime :time_capa


      #Atributos exclusivos de Eventos
      t.string :kind
      t.string :local_realiza
      t.datetime :inicio
      t.datetime :fim
      t.string :email

      
      #Atributos exclusivos de Informativos
      t.string :assunto
      t.string :texto_clob
      t.string :lado


      #Atributo exigido pelo STI
      t.string :type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :paginas
  end
end
