class ChangePaginaNameAndAttributes < ActiveRecord::Migration
  def self.up
    #Atributos em comum
    rename_column("paginas","dt_publica","date_pub")
    rename_column("paginas","dt_inicio","date_begin")
    rename_column("paginas","dt_fim","date_end")
    rename_column("paginas","imagem","image")
    rename_column("paginas","posicao","position")
    rename_column("paginas","autor_id","author_id")
    rename_column("paginas","editor","editor_id")
    rename_column("paginas","editor_chefe","editor_chief_id")
    rename_column("paginas","texto","text")
    #Atributos de Eventos e Notícias
    rename_column("paginas","fonte","source")
    rename_column("paginas","titulo","title")
    rename_column("paginas","texto_imagem","text_image")
    rename_column("paginas","resumo","summary")
    rename_column("paginas","capa","front")
    rename_column("paginas","time_capa","front_time")
    #Atributos exclusivos de Eventos
    rename_column("paginas","local_realiza","local")
    rename_column("paginas","inicio","event_begin")
    rename_column("paginas","fim","event_end")
    rename_column("paginas","email","event_email")
    #Atributos exclusivos de Informativos
    rename_column("paginas","assunto","subject")
    rename_column("paginas","texto_clob","text_clob")
    rename_column("paginas","lado","align")
    # Removendo coluna
    remove_column("paginas", "dt_cadastro")
    # Renomeando paginas para pages
    rename_table("paginas", "pages")
  end

  def self.down
    #Atributos em comum
    rename_column("pages","date_pub","dt_publica")
    rename_column("pages","date_begin","dt_inicio")
    rename_column("pages","date_end","dt_fim")
    rename_column("pages","image","imagem")
    rename_column("pages","position","posicao")
    rename_column("pages","author_id","autor_id")
    rename_column("pages","editor_id","editor")
    rename_column("pages","editor_chief_id","editor_chefe")
    rename_column("pages","text","texto")
    #Atributos de Eventos e Notícias
    rename_column("pages","source","fonte")
    rename_column("pages","title","titulo")
    rename_column("pages","text_image","texto_imagem")
    rename_column("pages","summary","resumo")
    rename_column("pages","front","capa")
    rename_column("pages","front_time","time_capa")
    #Atributos exclusivos de Eventos
    rename_column("pages","local","local_realiza")
    rename_column("pages","event_begin","inicio")
    rename_column("pages","event_end","fim")
    rename_column("pages","event_email","email")
    #Atributos exclusivos de Informativos
    rename_column("pages","subject","assunto")
    rename_column("pages","text_clob","texto_clob")
    rename_column("pages","align","lado")
    # Criando coluna
    add_column("pages", "dt_cadastro", :date) 
    # Renomeando de pages para paginas
    rename_table("pages", "paginas")
  end
end
