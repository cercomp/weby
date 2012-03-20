class AlterTableStylesDefineForeignKeys < ActiveRecord::Migration
  def up
    say "Creating foreign keys in styles and sites_styles"
    execute <<-SQL
    ALTER TABLE styles
    ADD CONSTRAINT fk_owner
    FOREIGN KEY (owner_id)
    REFERENCES sites(id)
    ON DELETE CASCADE; 

    ALTER TABLE sites_styles
    ADD CONSTRAINT fk_styles
    FOREIGN KEY (style_id)
    REFERENCES styles(id)
    ON DELETE CASCADE; 

    ALTER TABLE sites_styles
    ADD CONSTRAINT fk_sites
    FOREIGN KEY (site_id)
    REFERENCES sites(id)
    ON DELETE CASCADE;

    ALTER TABLE styles
    ALTER COLUMN name set NOT NULL;

    ALTER TABLE styles
    ALTER COLUMN owner_id set NOT NULL;

    SQL
  end

  def down
    say "Removing foreign keys in styles and sites_styles"
    execute <<-SQL
    ALTER TABLE styles
    DROP CONSTRAINT fk_owner;

    ALTER TABLE sites_styles
    DROP CONSTRAINT fk_styles;

    ALTER TABLE sites_styles
    DROP CONSTRAINT fk_sites;

    ALTER TABLE styles
    ALTER COLUMN name drop NOT NULL;

    ALTER TABLE styles
    ALTER COLUMN owner_id drop NOT NULL;

    SQL
  end
end
