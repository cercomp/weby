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


# 3. Vincula  novo perfil Gestor aos usuários que são administradores
# Busca as roles que possuem na coluna name o valor igual a 'Administrador'
admin_role_list = Role.where(name: 'Administrador')

# Percorre essa lista e atualiza a coluna 'name' com o valor 'Gestor' e a coluna 'permissions' com
# as permissões do papel Gestor
unless admin_role_list.empty?
  admin_role_list.each do |role|
    role.update!(name: 'Gestor', permissions:  roles_data.find { |r| r[:name] == 'Gestor' }[:permissions])
  end
end