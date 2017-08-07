# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile << proc { |path| Weby::Assets.should_compile?(path) }
