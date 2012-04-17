module SiteComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  #TODO - Documentar
  #
  def places_holder
    places = {
      'weby' => ['left', 'right', 'top', 'bottom', 'home', 'first_place'],
      'this2' => ['first_place', 'top', 'left', 'home', 'right', 'bottom'],
      'teachers' => ['first_place', 'top', 'left', 'home', 'bottom']
    }

    places[@site.theme] || []
  end

  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
     divs = "<div id='mini_layout'>"  
     places_holder.map { |position| divs += "<div id='mini_#{position}' class='hover'>
                                            #{t("components.pos.#{position}")}  </div>"} 
     divs += "</div>" 
  end

  #TODO -> Documentar
  #
  def components
    ['banner_horizontal',
     'banner_side',
     'menu_side',
     'feedback',
     'info_footer',
     'header',
     'menu_accessibility',
     'front_news',
     'no_front_news',
     'institutional_bar',
     'weby_bar',
     'news_as_home',
     'teacher_photo', 
     'gov_bar']
  end

  def components_settings
    {
      'banner_horizontal' => ['category'],
      'no_front_news'     => ['quant', 'front'],
      'banner_side'       => ['category'],
      'front_news'        => ['quant'],
      'menu_side'         => ['menu_id'],
      'news_as_home'      => ['page'],
      'gov_bar'           => ['background'],
      'teacher_photo'     => ['image', 'height', 'width'],
      'feedback'          => ['label']
    }
  end
  
  #TODO -> Documentar
  #
  def components_settings_custom_field
    cur_setting = eval(@site_component.settings);
    if(cur_setting[:page])
      cur_page = @site.pages.find(cur_setting[:page])
    end
    if(cur_setting[:image])
      cur_image = Repository.find(cur_setting[:image])
    end
    {
      'banner_horizontal' => {
        'category' => ['<select name="category">', options_for_select(@site.banners.category_counts.map{|b| b.name}, cur_setting[:category]), '</select>'].join
      },
      
      'banner_side' => {
        'category' => ['<select name="category">', options_for_select(@site.banners.category_counts.map{|b| b.name}, cur_setting[:category]), '</select>'].join
      },
      
      'menu_side' => {
        'menu_id' => ['<select name="menu_id">', options_for_select([['','']] + @site.menus.map{|menu| [menu.name, menu.id]}, cur_setting[:menu_id]), '</select>'].join
      },
      
      'no_front_news' => {
        'front' => '<input type="checkbox" name="front" value="true" />'
      },

      'news_as_home' => {
        'page' => [ (cur_page ? '<input type="text" disabled="disabled" value="'+cur_page.title+'"><input type="hidden" name="page" value="'+cur_page.id.to_s+'">' : '' )+ '<a onclick="show_dialog($(this)); return false;" data-link="'+site_pages_path+'">', t('select_param', :param => t('news.one')), '</a>'].join
      },

      'gov_bar' => {
        'background' => ['<select name="background">', options_for_select([["Azul","#004b82"],["Verde","#00500f"],["Cinza","#7f7f7f"],["Preto","#000000"]], cur_setting[:background]), '</select>'].join
      },

      # FIXME implementar novo modelo de componentes
      'teacher_photo' => {
        'image' => [repository_search( t("page.image"), "page_image", "image", cur_image, multiple: false, file_types: 'image'),
                    '<div id="dialog-repository-search">',
                    render('repositories/repository_search'),
                    '</div>'].join
      }

    }
  end
  
  #TODO -> Documentar o que o método faz
  #
  def components_settings_locales
    locales = {}
    self.components_settings.each do |component, array|
      locales[component] = []
      array.each do |v|
        locales[component] << t("components.config." + v);
      end
    end
    locales
  end
  
  #Método que retorna a categoria que um dados componente está relacionado
  def components_settings_category(site_component)
    if site_component.settings and site_component.settings.include? "category" 
      ini = site_component.settings.index('"')  
      fim = site_component.settings.rindex('"')  
      site_component.settings[ini+1..fim-1]
    elsif site_component.settings and site_component.settings.include? "menu_id"
      settings = eval(site_component.settings)
      menu = @site.menus.find_by_id(settings[:menu_id].to_i)
      return menu.name if menu
    end 
  end
end
