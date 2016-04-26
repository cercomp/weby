require 'weby'

::Weby::register_extension(Weby::Extension.new(:journal, author: 'Cercomp - Equipe Web', menu_position: :before_pages, settings: [:author, :created_at, :updated_at, :social_share_pos, :social_share_networks_]))
