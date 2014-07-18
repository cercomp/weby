module LocalesHelper
  def flag(locale, options = {})
    size = options.delete(:size) || :regular
    options.reverse_merge!(title: t(locale.name), class: 'flag')
    image_tag "data:image/png;base64,#{FLAGS[size][locale.name]}", options
  end

  def available_locales(obj)
    (obj.locales | current_site.locales).sort
  end

  def each_i18n_tab(locales = current_site.locales)
    @tab_count = @tab_count.to_i + 1
    content_tag :div, class: 'tabbable i18n' do
      tabs = content_tag :ul, class: 'nav nav-tabs' do
        locales.each_with_index.map do |locale, index|
          content_tag :li, link_to(locale_with_name(locale, :small), "#tab_#{locale}#{@tab_count}", data: { toggle: 'tab' }), class: (index == 0 ? 'active' : '')
        end.join('').html_safe
      end
      content = content_tag :div, class: 'tab-content' do
        locales.each_with_index.map do |locale, index|
          content_tag :div, id: "tab_#{locale.name}#{@tab_count}", class: "tab-pane#{index == 0 ? ' active' : ''}" do
            yield(locale) if block_given?
          end
        end.join('').html_safe
      end
      tabs + content
    end
  end

  private

  FLAGS = {
    :regular => {
      'en' => 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAV0lEQVRIx2P4//8/A'\
        'y0xw6gFRFnAwDDlP6kYrJUQRrZg2bKb/0mhSbaAFMPBFhAHBrMPaB4HpAbR4PPByExFNMvJ'\
        '/2kHoBYQ4xpyMP0sGPpBNFplDqQFAPxE+utlvEu1AAAAAElFTkSuQmCC',
      'es' => 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAA/0lEQVRIiWP4//8/A'\
        'y0xTQ0fRhYc45b7Tws8agHxFvw/AqTQ8TEgPgHFx7DIE4NxWgA09N029v/X5vL/vzqH7/+7'\
        'rWz//x+nlgVHGf5/3MXw//JEjv+z/Pn/zwzg/X+hn+3/x91UtODCKrn/R4u5/0+2lfq/taP'\
        't/5VNUf/PLpWhggVAw//sZ/h/utPp/ypfyf8Ftvr/F9bO/n9qVt3/Y622/3/vg6ihyAKQIZ'\
        'dmuv4/VMf/v8tF8v9kD+X/J8tk/p+f5v7/1x5KLQDiv4cZ/29bbvv/9DS+/+sLVf5vTdH4f'\
        '66d//+W5Xb//xxiolIqohYePjl56Fsw9Gu0IW0BABduyy3NGP7OAAAAAElFTkSuQmCC',
      'fr' => 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAANUlEQVRIiWP4//8/A'\
        'y0xTQ0fRhYwhC75jwsTAu8dTXHiUQtGLRi1YNSCUQuGlgW0xKMWEMQARV2D+0evqEEAAAAA'\
        'SUVORK5CYII=',
      'pt-BR' => 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAC5ElEQVRIx+2VW0'\
        'jTcRTH/6BumreFts3pLrIxL3mZt9TIyzQCFROFVtBTgT5YzmtTQ8V8iFJsbpqZijZEjcxCs'\
        'ZKR6HKZGV18KYQgJHqJXnqIJGbffv/fXw2lyDTpxYfD4Pc/3/P5nfM754wBwOykMbuATQEY'\
        'cwp2wjYPaEkDn/zWDClQNySHqzmZnm0fYEoFY0xHUo8GL21uwDxDbd7mitTeSPqN+mwJYEy'\
        'DoO0QjCP+cMySoN1idJTHUHvV5QfHEwamUQn2Eh/Wd/MAk5YKsm+E4c2UG74+dEJhVibkXq'\
        'WQ7DHA390AhaCcnGVjacIFCySzHEsYV7IW7R8AJOWA9kT0jIiAGfLpKYOy43lQiuuhURig9'\
        'tFD4V6IQM+zEPKrUJBxFCDZsb6WURFk1xK5splTNwBYMrHT/UF4P8mjguXHDBatEagz3oGh'\
        '0YKL5iGY28dQXtOLvOxGKL2LIHEtwaN2KfCMg3yY4iF/QM29C4m3BgjvjMPEuIA6fbczWJo'\
        'mx88ZdBoSoNpXS28e7l+GhJBq6HKbUX9lEPWtAziguYSm/BjgBadhtWyMyXFvRHbG/gREd8'\
        'Vg1urJ3XwVQESt+jhIPasQKi7Bfr9ShIhKEORTjECPMziSfAE1pjFM9B/D8gynWV4BzFk9E'\
        'EtiriuRkykF+kEVPtqcufrPMSR9GYLF5xEdWIlgYTE08gpEKc5B7auHSlCEWHUDXt+NXHuH'\
        'T0RbelMJZzo72g2PvNLzqo543BrzBUgbsnbqcA5kglpESCtoJmypouQGBPk1oCBLh282zu8'\
        '20aivx6+bjV+36cqDn+gLxbtpPr5Y+QSSS0pVAYk726aVUPlWoyBTh88PeFi083CyL2RN9x'\
        'eDlg7h1YPovieiNZ5pk6G5MJGa3SyDg3RZz30hxMSHa80trQpu6DIs4VggN11dFW/tLshih'\
        '4udYJP2Hyw7EsijNQmXh6VoGg6AV1vSb9fD1gDbXde7f5n/FfADm5xsWPqXnOoAAAAASUVO'\
        'RK5CYII='
    },
    :small => {
      'en' => 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAP0lEQVQ4y2P4//8/A'\
        'yWYgSoGrF59B8ia8h8ffQaoFB3DDSCkGUTjAKMuoJoL/pMPIAZgM50YPLhcMMCZiRIMAPDV'\
        'yT6O2d4qAAAAAElFTkSuQmCC',
      'es' => 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAApElEQVQ4y2P4//8/A'\
        'yWYgSoGHOOW+08OHkQG/D8CpED4KMP/v0eY/n/ezfz/7yEIHy6HDaMYAFT8C4ivTWP7vzRO'\
        '4v/1eXz/fx0hYAiKAccZ/n/YLvx/TazE/4lRcf+Pz837/3oDL1icaANebZL9v7lU5X+/p/r'\
        '/veWW/59vlCbBAKBTP+7n/v9kC///R0uE/z9Zy/v/wwEe4rwwHNLBgGcmSjAAM6iPdeK4sE'\
        'kAAAAASUVORK5CYII=',
      'fr' => 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAK0lEQVQ4y2P4//8/A'\
        'yWYgSoGMIQu+Y+O0cF7R1MMPGrAqAGDzICBz0yUYAB6SdABZGnejAAAAABJRU5ErkJggg==',
      'pt-BR' => 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABd0lEQVQ4y2P4//'\
        '8/AyWYgSoGMEyy/08Oxm3ABMf/DBMd/qesVv6fCsQgNliMsAFAhX3O/9XmmP5fsVnk//WFo'\
        'kAs9n/VFpH/GkAxkBxYDVYDJjj9ZwTalLNS5f/dbVz/8z39/ivwFv6X4cj7n+3s8//edq7/'\
        'eauU/zOBXeOEagBI0HSO8f9d2wX+/z/N8H/TtMD//hFz/6elzPwfGTHhv4p08//2OPP//88'\
        'z/N8DVGM2xwhsENwAnVmm/18dZPn//yQDGCd5hP1XEq74b6RU9t/Ntul/ZMKs/81lef//HY'\
        'XIvznI/F93lgmqC8yBpu7dwQ+2pT/D5r8MX91/bcmi/+oiBf+luGv/L231/f//HMP/fUA1F'\
        'mAXYAkDZqBgPtCf94FhkOfh/19JoPi/qkjp/2K/kP93NnH+LwDGCEgNRhjAY2EiJBZAIb4K'\
        'GAvXFoj9vzpf7P9qIFtrjgkkFiY6EJ8O0tYo/89YowSJOuLSAZkpceAzEyUYAA+lZk4tsyt'\
        'LAAAAAElFTkSuQmCC'
    }
  }
end
