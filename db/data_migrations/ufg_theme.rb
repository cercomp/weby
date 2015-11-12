# Migrate sites to UFG theme

Style.where(style_id: 1072).find_each do |follower|
  follower.skin.update(theme: 'ufg', name: 'UFG')
  follower.skin.styles.where(style_id: [3595, 1101, 1082, 1095, 1085, 1089, 1084, 1081, 1080,
                                        1079, 1078, 1076, 1077, 1075, 1074, 1073, 1072, 1071]).destroy_all

end

# PPGS empty site
Site.find(677).skins.find_by(theme: 'weby').update(theme: 'ufg', name: 'UFG')