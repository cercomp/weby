require 'weby'

::Weby::register_extension(Weby::Extension.new(:feedback, author: 'Cercomp - Equipe Web', settings: [:text, :label_as_placeholder]))
