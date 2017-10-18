class ThemeMigration
  class << self

    # Migrate sites to UFG theme
    def migrate_to_ufg
      Style.where(style_id: 1072).find_each do |follower|
        follower.skin.update(theme: 'ufg', name: 'UFG')
        follower.skin.styles.where(style_id: [3595, 1101, 1082, 1095, 1085, 1089, 1084, 1081, 1080,
                                              1079, 1078, 1076, 1077, 1075, 1074, 1073, 1072, 1071]).destroy_all
      end

      # PPGS empty site
      Site.find(677).skins.find_by(theme: 'weby').update(theme: 'ufg', name: 'UFG')
    end

    # update ufg theme
    def update_ufg site_id
      if site_id == :all
        Skin.where(theme: 'ufg').each do |skin|
          comply_ufg_skin(skin.id)
        end
        puts "Done!"
      elsif site_id.to_s.match(/\d+/)
        site = Site.find(site_id)
        skin = site.skins.find_by(theme: 'ufg')
        comply_ufg_skin(skin.id)
      end
    end

    private

    def comply_ufg_skin skin_id
      skin = Skin.find_by(theme: 'ufg', id: skin_id)
      site = skin.site
      site_components = skin.components
      top_components = Weby::Themes.theme('ufg').components.select{|place, c| place == 'top' }['top']

      #site width
      site.update_columns(body_width: nil)

      #accessibility
      theme_access = top_components.detect{|c| c['name'] == 'menu_accessibility' }
      access = site_components.detect{|c| c.name == 'menu_accessibility' }
      access.update_columns(position: 1, place_holder: 'top', settings: theme_access['settings']) if access

      #group cabeçalho
      gheader = site_components.detect{|c| c.name == 'components_group' && c.alias == 'Cabeçalho' }
      if gheader
        gheader.update_columns(position: 2, settings: '{:html_class=>"cabecalho"}')
      end

      # logos
      glogos = site_components.detect{|c| c.name == 'components_group' && c.alias == 'Logos' }
      if glogos
        imgs = site_components.select{|c| c.place_holder == glogos.id.to_s }
        ufgimg = imgs.delete( imgs.detect{|c| c.alias.to_s.match(/(UFG|ufg)/) } )
        siteimg = imgs.first
        #fix classes
        if ufgimg
          ufgimg.update_columns(settings: '{:default_image=>"ufg_topo.svg", :size=>"original", :width=>"", :height=>"", :url=>"http://www.ufg.br", :target_id=>"", :html_class=>"ufglogo", :target_type=>"", :new_tab=>"0"}')
        end
        if siteimg
          sett = eval(siteimg.settings)
          sett[:html_class] = 'sitelogo'
          siteimg.update_columns(settings: sett.to_s)
        end
      end

      #info header
      ginfo_header = site_components.detect{|c| c.name == 'components_group' && c.alias == 'Info Header' }
      ginfo_header.update_columns(position: 2) if ginfo_header

      #i18n
      mi18n = site_components.detect{|c| c.name == 'menu_i18n' }
      mi18n.update_columns(position: 1) if mi18n

      #menu box group
      unless site_components.detect{|c| c.alias == 'Barra do Menu' }
        mbar = site_components.create(
          place_holder: 'top',
          settings: '{:html_class=>"menu-bar"}',
          name: 'components_group',
          position: 3,
          publish: true,
          alias: 'Barra do Menu'
        )
      end

      mbox = site_components.detect{|c| c.alias == 'Menu' && c.name == 'components_group' }
      if !mbox
        mbox = site_components.create(
          place_holder: mbar.id,
          settings: '{:html_class=>"menu-box"}',
          name: 'components_group',
          position: 1,
          publish: true,
          alias: 'Menu'
        )

        fixed_logo = site_components.create(
          place_holder: mbox.id,
          settings: '{:html_class=>"fixed-bar-logo", :default_image=>"ufg_barra.svg", :size=>"original", :width=>"", :height=>"", :url=>"/", :target_id=>"", :target_type=>"", :new_tab=>"0"}',
          name: 'image',
          position: 2,
          publish: true,
          alias: 'Logo'
        )
      end

      #menu
      menu = site_components.detect{|c| c.name == 'menu' && c.place_holder == 'top' }
      if menu
        sett = eval(menu.settings)
        sett[:style] = 'hamburger'
        menu.update_columns(position: 1, settings: sett.to_s, place_holder: mbox.id)
      end

      #search
      search = site_components.detect{|c| c.name == 'search_box' }
      if search
        search.update_columns(position: 3, settings: '{:width=>"340", :align=>"left", :show_button=>"1"}', place_holder: mbox.id)
      end
      links = site_components.detect{|c| c.name == 'institutional_links' }
      links.update_columns(position: 4, place_holder: mbox.id) if links

      gbusca = site_components.detect{|c| c.alias == 'Portal Busca' }
      gbusca.destroy if gbusca

      # slider
      slider = site_components.detect{|c| c.alias == 'Slider' && c.place_holder == 'top' }
      slider.update_columns(position: 4) if slider

    end
  end
end