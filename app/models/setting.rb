# Configurações usadas atualmente
#
# per_page:          opções de escolha de quantidade de itens por página em listagens
# per_page_default:  padrão de itens por página em listagens
# default_locale:    idioma padrão
# help_site:         url do site para o link 'ajuda'
# tld_length:        tamanho do domínio onde o weby está rodando Ex: 'weby.com.br' tld_length=2, 'weby.br' tld_length=1(padrão)
# sites_index:       site_id para mostrar a listagem dos sites, se não existir essa propriedade será o root do domínio
# login_protocol:    protocolo da página de login (opções 'http' e 'https', padrão=http)
#
class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :value, :description

  validates :value, format: {with: /^https?$/}, if: :is_login_protocol?

  def is_login_protocol?
    self.name == "login_protocol"
  end
  
end
