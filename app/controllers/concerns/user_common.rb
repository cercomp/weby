module UserCommon
  extend ActiveSupport::Concern
  
  def change_roles
    params[:role_ids] ||= []
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!

    user_ids.each do |user_id|
      user = User.find(user_id)
      # Limpa os papeis do usuário no site
      user.role_ids.each do |role_id|
        if @site and @site.roles.map{|r| r.id }.index(role_id)
          user.role_ids -= [role_id]
        end
      end
      
      # Se for global, limpa os papeis globais
      unless @site
        user.roles.where(site_id: nil).each{|r| user.role_ids -= [r.id] }
      end
      # NOTE Talvez seja melhor usar (user.role_ids += params[:role_ids]).uniq
      # assim removemos o each logo a cima
      user.role_ids += params[:role_ids]
    end
    redirect_to :action => 'manage_roles'
  end
end
 
