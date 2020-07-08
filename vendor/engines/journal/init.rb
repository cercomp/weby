require 'weby'

::Weby::register_extension(Weby::Extension.new(:journal, author: 'Cercomp - Equipe Web', menu_position: :before_pages, settings: [:show_author, :show_created_at, :show_updated_at, :image_size]))
