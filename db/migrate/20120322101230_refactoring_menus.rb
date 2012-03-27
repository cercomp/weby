class RefactoringMenus < ActiveRecord::Migration
  def up
    rename_table :menus, :old_menus
    execute <<-SQL
      ALTER TABLE menus_id_seq RENAME TO old_menus_id_seq;
    SQL

    create_table :menus do |t|
      t.references :site, null: false
      t.string :name

      t.timestamps
    end
    say "Creating constraints to foreign keys"
    execute <<-SQL
      ALTER TABLE menus ADD CONSTRAINT site_menus FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;
    SQL

    create_table :menu_items do |t|
      t.references :menu, null: false
      t.boolean :separator, default: false
      t.references :target, polymorphic: true
      t.string :url
      t.integer :parent_id, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.boolean :new_tab, default: false

      t.timestamps
    end
    say "Creating constraints to foreign keys"
    execute <<-SQL
      ALTER TABLE menu_items ADD CONSTRAINT menu_menu_items FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE;
    SQL

    create_table :menu_item_i18ns do |t|
      t.references :menu_item, null: false
      t.references :locale, null: false
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
    say "Creating constraints to foreign keys"
    execute <<-SQL
      ALTER TABLE menu_item_i18ns ADD CONSTRAINT menu_item_menu_item_i18ns FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE;
      ALTER TABLE menu_item_i18ns ADD CONSTRAINT locale_menu_item_i18ns FOREIGN KEY (locale_id) REFERENCES locales(id) ON DELETE RESTRICT;
      ALTER TABLE menu_item_i18ns ADD UNIQUE (menu_item_id, locale_id)
    SQL

    # Pega os menus antigos e popula o novo esquema de menu e menu_item
    con = ActiveRecord::Base.connection
    sql = "SELECT site_id, category FROM sites_menus GROUP BY site_id, category ORDER BY site_id"
    con.execute(sql).each{ |row|
      Menu.create({
          site_id: row['site_id'],
          name: row['category']
      })
    }
    default_locale = Locale.find_by_name 'pt-BR'
    sql = "SELECT sm.id, me.id as menu_id, om.link, om.page_id, pa.type, sm.parent_id, sm.position, om.title, om.description
           FROM sites_menus sm
            INNER JOIN old_menus om ON om.id = sm.menu_id
            INNER JOIN menus me ON (me.name = sm.category AND me.site_id = sm.site_id)
            LEFT OUTER JOIN pages pa ON pa.id = om.page_id"
    con.execute(sql).each{ |row|
      item = MenuItem.new({
         menu_id: row['menu_id'],
         url: row['link'],
         target_id: row['page_id'],
         target_type: row['type'],
         parent_id: row['parent_id'],
         position: row['position']
      })

      item.i18ns.new({
        menu_item_id: item.id,
        locale_id: default_locale.id,
        title: row['title'],
        description: row['description']
      })

      item.id = row['id']
      item.save
    
    }
    SiteComponent.where(component: 'menu_side').each{ |component|
        setting = eval(component.settings);
        menu = Menu.where(name: setting[:category], site_id: component.site_id).first
        component.update_attribute(:settings, menu ? "{:menu_id => \"#{menu.id}\"}" : "{:menu_id => \"0\"}")
    }
    execute <<-SQL
      SELECT SETVAL('menu_items_id_seq', (SELECT MAX(id) FROM menu_items) + 1);
      TRUNCATE TABLE old_menus;
      SELECT SETVAL('old_menus_id_seq', 1);
      TRUNCATE TABLE sites_menus;
      SELECT SETVAL('sites_menus_id_seq', 1);
    SQL

    #menu -> order id=20
    r_order = Right.find_by_id(20)
    if r_order
      r_order.update_attributes({name: 'Ordenar Itens de Menu', controller: 'menu_items', action: 'change_position change_order change_menu'})
    end
    
    #menu -> index id=16
    if(Right.where(controller: 'menu_items', action: 'index').length == 0)
      r_index = Right.create({name: 'Listar Itens de Menu', controller: 'menu_items', action: 'index'})
      RightsRole.where(right_id: 16).each do |rightrole|
        RightsRole.create({right_id: r_index.id, role_id: rightrole.role_id})
      end
    end
    #menu -> show id=17
    if(Right.where(controller: 'menu_items', action: 'show').length == 0)
      r_show = Right.create({name: 'Ver Item de Menu', controller: 'menu_items', action: 'show'})
      RightsRole.where(right_id: 17).each do |rightrole|
        RightsRole.create({right_id: r_show.id, role_id: rightrole.role_id})
      end
    end
    #menu -> edit id=18
    if(Right.where(controller: 'menu_items', action: 'edit update').length == 0)
      r_edit = Right.create({name: 'Editar Item de Menu', controller: 'menu_items', action: 'edit update'})
      RightsRole.where(right_id: 18).each do |rightrole|
        RightsRole.create({right_id: r_edit.id, role_id: rightrole.role_id})
      end
    end
    #menu -> destroy id=19
    if(Right.where(controller: 'menu_items', action: 'destroy rm_menu').length == 0)
      r_destroy = Right.create({name: 'Excluir Item de Menu', controller: 'menu_items', action: 'destroy rm_menu'})
      RightsRole.where(right_id: 19).each do |rightrole|
        RightsRole.create({right_id: r_destroy.id, role_id: rightrole.role_id})
      end
    end
    #menu -> new id=21
    if(Right.where(controller: 'menu_items', action: 'new create').length == 0)
      r_new = Right.create({name: 'Criar Item de Menu', controller: 'menu_items', action: 'new create'})
      RightsRole.where(right_id: 21).each do |rightrole|
        RightsRole.create({right_id: r_new.id, role_id: rightrole.role_id})
      end
    end

  end

  def down
    #menu -> order id=20
    r_order = Right.find_by_id(20)
    if r_order
      r_order.update_attributes({name: 'Ordenar Menus', controller: 'menus', action: 'change_position change_order change_category'})
    end
    
    Right.where(controller: 'menu_items').each do |right|
      RightsRole.where(right_id: right.id).each do |rightrole|
        rightrole.delete
      end
      right.delete
    end

    Menu.all.each{ |menu|
      menu.menu_items.each{ |menu_item|
        execute <<-SQL
          INSERT INTO old_menus(title,link,created_at,updated_at,page_id,description)
          VALUES('#{menu_item.i18n('pt-BR').title}','#{menu_item.url}','#{menu_item.created_at}','#{menu_item.updated_at}',#{menu_item.target_id.to_i},'#{menu_item.i18n('pt-BR').description}');
        SQL
        
        execute <<-SQL
          INSERT INTO sites_menus(id,site_id,menu_id,created_at,updated_at,parent_id,category,position)
          VALUES(#{menu_item.id},#{menu.site_id},(SELECT currval('old_menus_id_seq')),'#{menu_item.created_at}','#{menu_item.updated_at}',#{menu_item.parent_id.to_i},'#{menu.name}',#{menu_item.position.to_i});
        SQL
      }
    }
    SiteComponent.where(component: 'menu_side').each{ |component|
        setting = eval(component.settings);
        menu = Menu.find_by_id(setting[:menu_id].to_i)
        component.update_attribute(:settings, menu ? "{:category => \"#{menu.name}\"}" : "{:category => \"\"}")
    }
    execute <<-SQL
      SELECT SETVAL('sites_menus_id_seq', (SELECT MAX(id) FROM sites_menus) + 1);
    SQL

    drop_table :menu_item_i18ns
    drop_table :menu_items
    drop_table :menus
        

    rename_table :old_menus, :menus
    execute <<-SQL
      ALTER TABLE old_menus_id_seq RENAME TO menus_id_seq;
    SQL

  end
end
