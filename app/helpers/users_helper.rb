module UsersHelper
  # Retorna um hash contendo o site e os papeis que o usuaŕio possui
  # Exemplo: { 'Matematica' => [role1, role2] }
  def sites_with_roles
    sites = {}
    @user.roles.order(:site_id).each do |r|
      role_site_name = r.site.try(:name)
      sites[role_site_name] = [] if sites[role_site_name] == nil
      sites[role_site_name] << r
    end
    sites
  end
end
