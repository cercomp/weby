# 1. Define os dados a serem inseridos
roles_data = [
  {
    name: 'Editor-Chefe',
    permissions: {
      "banners"     => ["index", "show", "edit", "destroy", "change_position", "new", "share", "unshare"],
      "components"  => ["index", "show", "new"],
      "events"      => ["index", "show", "edit", "destroy", "new", "purge", "recover"],
      "groups"      => ["index", "show", "new"],
      "menu_items"  => ["change_position", "index", "show", "edit", "new"],
      "menus"       => ["index", "show", "edit", "destroy", "new"],
      "messages"    => ["index", "show", "edit", "new"],
      "news"        => ["index", "show", "edit", "share", "unshare", "destroy", "sort", "new", "recover", "newsletter"],
      "newsletters" => ["index"],
      "pages"       => ["index", "show", "edit", "destroy", "new", "recover"],
      "repositories"=> ["index", "show", "edit", "crop", "destroy", "new", "recover"],
      "statistics"  => ["index"],
      "styles"      => ["index", "show", "edit", "destroy", "new", "follow", "copy", "sort"]
    },
    site_id: nil
  },
  {
    name: 'Redator',
    permissions: {
      "events"      => ["index", "show", "edit", "new"],
      "groups"      => ["index", "show", "edit", "new"],
      "menu_items"  => ["index", "show"],
      "menus"       => ["index", "show", "edit", "new"],
      "messages"    => ["index", "show", "new"],
      "news"        => ["index", "show", "edit", "share", "unshare", "destroy", "sort", "new", "recover", "newsletter"],
      "newsletters" => ["index"],
      "pages"       => ["index", "show", "edit", "destroy", "new", "recover"],
      "repositories"=> ["index", "show", "crop", "new"]
    },
    site_id: nil
  },
  {
    name: 'Gestor',
    permissions: {
      "activity_records" => ["index"],
      "album_photos"     => ["edit", "destroy", "new"],
      "album_tags"       => ["index", "edit", "destroy", "new"],
      "albums"           => ["index", "show", "edit", "destroy", "new"],
      "banners"          => ["index", "show", "edit", "destroy", "change_position", "new", "share", "unshare"],
      "components"       => ["index", "show", "edit", "new"],
      "events"           => ["index", "show", "edit", "destroy", "new", "purge", "recover"],
      "extensions"       => ["index", "new", "destroy"],
      "groups"           => ["index", "show", "edit", "destroy", "new"],
      "menu_items"       => ["change_position", "index", "show", "edit", "destroy", "new"],
      "menus"            => ["index", "show", "edit", "destroy", "new"],
      "messages"         => ["index", "show", "edit", "destroy", "new"],
      "news"             => ["index", "show", "edit", "share", "unshare", "destroy", "sort", "new", "purge", "recover", "newsletter"],
      "newsletters"      => ["index", "destroy"],
      "pages"            => ["index", "show", "edit", "destroy", "new", "purge", "recover"],
      "repositories"     => ["index", "show", "edit", "crop", "destroy", "new", "purge", "recover"],
      "statistics"       => ["index"],
      "styles"           => ["index", "show", "edit", "destroy", "new", "follow", "copy", "sort"],
      "users"            => ["manage_roles", "change_roles"]
    },
    site_id: nil
  },
  {
    name: 'Gerente',
    permissions: {
      "activity_records" => ["index"],
      "album_photos"     => ["edit", "destroy", "new"],
      "album_tags"       => ["index", "edit", "destroy", "new"],
      "albums"           => ["index", "show", "edit", "destroy", "new"],
      "banners"          => ["index", "show", "edit", "destroy", "change_position", "new", "share", "unshare"],
      "components"       => ["index", "show", "edit", "new"],
      "events"           => ["index", "show", "edit", "destroy", "new", "purge", "recover"],
      "groups"           => ["index", "show", "edit", "destroy", "new"],
      "menu_items"       => ["change_position", "index", "show", "edit", "destroy", "new"],
      "menus"            => ["index", "show", "edit", "destroy", "new"],
      "messages"         => ["index", "show", "edit", "destroy", "new"],
      "news"             => ["index", "show", "edit", "share", "unshare", "destroy", "sort", "new", "purge", "recover", "newsletter"],
      "newsletters"      => ["index", "destroy"],
      "pages"            => ["index", "show", "edit", "destroy", "new", "purge", "recover"],
      "repositories"     => ["index", "show", "edit", "crop", "destroy", "new", "purge", "recover"],
      "statistics"       => ["index"],
      "styles"           => ["index", "show", "edit", "destroy", "new", "follow", "copy", "sort"]
    },
    site_id: nil
  }
]


# 2. Para cada papel, verifica se já existe e atualiza ou cria
roles_data.each do |role_new|
  # Busca todas as roles
  role_list = Role.where(name: role_new[:name])

  if role_list.any?
    role_list.each do |role|
      # Atualiza para as nova permissões
      role.update!(permissions: role_new[:permissions].to_s)
      puts "Permissões atualizadas para o papel: #{role_new[:name]}"
    end
  else
    # Cria novo papel
     Role.create!(
      name: role_new[:name],
      site_id: role_new[:site_id],
      permissions: role_new[:permissions].to_s
    )
    puts "Novo papel criado: #{role_new[:name]}"
  end
end


# 3. Reordena os IDs dos papéis seguindo a hierarquia (Gestor > Gerente > Editor-Chefe > Redator)
  # Define a ordem hierárquica desejada
hierarchy_order = ['Gestor', 'Gerente', 'Editor-Chefe', 'Redator']

# Busca todos os papéis com site_id NULL
roles_with_null_site = Role.where(site_id: nil).order(:id)

unless roles_with_null_site.empty?
  # Coleta os IDs existentes em ordem crescente
  existing_ids = roles_with_null_site.pluck(:id).sort
  
  # Cria um mapeamento de papel atual -> novo ID baseado na hierarquia
  id_mapping = {}
  
  hierarchy_order.each_with_index do |role_name, index|
    role = roles_with_null_site.find { |r| r.name == role_name }
    if role && existing_ids[index]
      id_mapping[role.id] = existing_ids[index]
    end
  end
  
  # Aplica a reordenação usando uma transação para garantir consistência
  ActiveRecord::Base.transaction do
    # Desabilita temporariamente as restrições de chave estrangeira
    ActiveRecord::Base.connection.execute("SET session_replication_role = replica;")
    
    # PRIMEIRO: Atualiza as referências em roles_users ANTES de alterar os IDs das roles
    if ActiveRecord::Base.connection.table_exists?('roles_users')
      id_mapping.each do |old_id, new_id|
        if old_id != new_id
          # Move as referências para IDs temporários negativos primeiro
          ActiveRecord::Base.connection.execute("UPDATE roles_users SET role_id = #{-new_id} WHERE role_id = #{old_id}")
          puts "Atualizando referência roles_users: #{old_id} -> #{-new_id} (temporário)"
        end
      end
    end
    
    # SEGUNDO: Move todos os IDs das roles para valores temporários negativos
    id_mapping.each do |old_id, new_id|
      if old_id != new_id
        ActiveRecord::Base.connection.execute("UPDATE roles SET id = #{-old_id} WHERE id = #{old_id}")
        puts "Movendo temporariamente ID da role #{old_id} para #{-old_id}"
      end
    end
    
    # TERCEIRO: Move para os IDs finais nas roles
    id_mapping.each do |old_id, new_id|
      if old_id != new_id
        ActiveRecord::Base.connection.execute("UPDATE roles SET id = #{new_id} WHERE id = #{-old_id}")
        puts "ID da role reordenado: #{old_id} -> #{new_id}"
      end
    end
    
    # QUARTO: Finaliza a atualização das referências em roles_users
    if ActiveRecord::Base.connection.table_exists?('roles_users')
      id_mapping.each do |old_id, new_id|
        if old_id != new_id
          ActiveRecord::Base.connection.execute("UPDATE roles_users SET role_id = #{new_id} WHERE role_id = #{-new_id}")
          puts "Finalizando atualização roles_users: #{-new_id} -> #{new_id}"
        end
      end
    end
    
    # Reabilita as restrições de chave estrangeira
    ActiveRecord::Base.connection.execute("SET session_replication_role = DEFAULT;")
  end
  
  puts "Reordenação de papéis concluída!"
end


# 4. Vincula  novo perfil Gestor aos usuários que são administradores
# Busca as roles que possuem na coluna name o valor igual a 'Administrador'
admin_role_list = Role.where(name: 'Administrador')

# Percorre essa lista e atualiza a coluna 'name' com o valor 'Gestor' e a coluna 'permissions' com
# as permissões do papel Gestor
unless admin_role_list.empty?
  admin_role_list.each do |role|
    role.update!(name: 'Gestor', permissions:  roles_data.find { |r| r[:name] == 'Gestor' }[:permissions])
  end
end