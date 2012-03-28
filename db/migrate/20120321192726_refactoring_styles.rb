class RefactoringStyles < ActiveRecord::Migration
  def up
    add_column :styles, :publish, :boolean
    add_column :styles, :owner_id, :integer

    SitesStyle.all.each do |site_style|
      if site_style.owner == true
        style = Style.find(site_style.style_id)
        if style.owner_id.nil?
          style.update_attributes!(owner_id: site_style.site_id)
        else 
          newstyle = Style.new(name: style.name, css: style.css, owner_id: site_style.site_id)
          newstyle.save!
          site_style.update_attributes!(style_id: newstyle.id)
        end
      end
    end

    Style.where(owner_id: nil).each do |style|
      style.delete
    end
    
    Style.all.each do |style|
      site_style = SitesStyle.where(site_id: style.owner_id, style_id: style.id).first
      style.update_attributes!(publish: site_style.publish)
      site_style.delete
    end
    
    remove_column :sites_styles, :owner

    #say "Creating foreign keys in styles and sites_styles"
    #execute <<-SQL
    #ALTER TABLE styles
    #ADD CONSTRAINT fk_owner
    #FOREIGN KEY (owner_id)
    #REFERENCES sites(id)
    #ON DELETE CASCADE; 

    #ALTER TABLE sites_styles
    #ADD CONSTRAINT fk_styles
    #FOREIGN KEY (style_id)
    #REFERENCES styles(id)
    #ON DELETE CASCADE; 

    #ALTER TABLE sites_styles
    #ADD CONSTRAINT fk_sites
    #FOREIGN KEY (site_id)
    #REFERENCES sites(id)
    #ON DELETE CASCADE;

    #ALTER TABLE styles
    #ALTER COLUMN name set NOT NULL;

    #ALTER TABLE styles
    #ALTER COLUMN owner_id set NOT NULL;

    #SQL
  end

  def down
    add_column :sites_styles, :owner, :boolean

    #say "Removing foreign keys in styles and sites_styles"
    #execute <<-SQL
    #ALTER TABLE styles
    #DROP CONSTRAINT fk_owner;

    #ALTER TABLE sites_styles
    #DROP CONSTRAINT fk_styles;

    #ALTER TABLE sites_styles
    #DROP CONSTRAINT fk_sites;

    #ALTER TABLE styles
    #ALTER COLUMN name drop NOT NULL;

    #ALTER TABLE styles
    #ALTER COLUMN owner_id drop NOT NULL;

    #SQL

    Style.all.each do |style|
      site_style = SitesStyle.new(site_id: style.owner_id, style_id: style.id, publish: style.publish)
      site_style.save!
    end

    Style.all.each do |style|
      site_style = SitesStyle.where(style_id: style.id, site_id: style.owner_id).first
      site_style.update_attributes!(owner: true)
      style.update_attributes!(owner_id: nil)
    end

    SitesStyle.where(owner: nil).each do |site_style|
      site_style.update_attributes!(owner: false)
    end

    remove_column :styles, :publish 
    remove_column :styles, :owner_id 
  end
end
