module UsersHelper
  # Retorna um hash contendo o site e os papeis que o usuaŕio possui
  # Exemplo: { 'Matematica' => [role1, role2] }
  def sites_with_roles
    sites = {}
    @user.roles.order(:site_id).each do |r|
      sites[r.site.name] = [] if sites[r.site.name] == nil
      sites[r.site.name] << r
    end
    sites
  end
end
