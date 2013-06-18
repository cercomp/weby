module UsersHelper
  # Retorna um hash contendo o site e os papeis que o usuaŕio possui
  # Exemplo: { 'Matematica' => [role1, role2] }
  def sites_with_roles
    sites = {}
    @user.roles.order(:site_id).each do |r|
      role_site_title = r.site.try(:title)
      (sites[role_site_title] ||= []) << r
    end
    sites
  end
  
  # Maneira de realizar um camel case do nome do usuário, assim mesmo que ele escreva
  # o nome em uppercase, será mostrado em camelcase.
  # NOTE procurei no ruby uma função para isso e não achei
  def captalize_name(user)
    [user.first_name, user.last_name].join(' ').split.map{ |word| word.capitalize }.join(' ')
  end
end
