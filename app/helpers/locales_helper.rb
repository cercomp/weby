module LocalesHelper
  def flag(locale, options = {})
    size = options.delete(:size) || :regular
    options.reverse_merge!(title: t(locale.name), class: 'flag')
    #image_tag "data:image/png;base64,#{FLAGS[size][locale.name]}", options
    [
      image_tag(SVGS[locale.name], options),
      (content_tag(:span, t(locale.name), class: 'lang-name') if options[:show_name])
    ].compact.join(' ').html_safe
  end

  def available_locales(obj)
    (obj.locales | current_site.locales).sort
  end

  def each_i18n_tab(locales = current_site.locales.order(:id))
    @tab_count = @tab_count.to_i + 1
    content_tag :div, class: 'tabbable i18n' do
      tabs = content_tag :ul, class: 'nav nav-tabs' do
        locales.each_with_index.map do |locale, index|
          content_tag :li, link_to(locale_with_name(locale, :small), "#tab_#{locale}#{@tab_count}", data: { toggle: 'tab' }), class: (index == 0 ? 'active' : '')
        end.join('').html_safe
      end
      content = content_tag :div, class: 'tab-content' do
        locales.each_with_index.map do |locale, index|
          content_tag :div, id: "tab_#{locale.name}#{@tab_count}", class: "tab-pane#{index == 0 ? ' active' : ''}", data: {locale: locale.name} do
            yield(locale) if block_given?
          end
        end.join('').html_safe
      end
      tabs + content
    end
  end

  def locale_link locale, template, options={}
    _text = case template
      when 'code'
        locale.code
      when 'flag_name'
        flag(locale, show_name: true)
      else
        flag(locale)
      end
    _opts = {class: 'locale-link', data: {locale: locale.name}}
    _newlocale = current_site.locales.map(&:name).include?(locale.name) ? locale.name : I18n.default_locale
    link_to _text, {locale: _newlocale, atr: (locale.name if options[:auto_translate])}, _opts
  end

  def translate_class obj
    res = nil
    if obj.respond_to?(:which_locale)
      res = 'skiptranslate' if obj.which_locale.name == current_locale && current_locale != 'pt-BR'
    end
    res
  end

  private

  SQUARE_FLAGS = {
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

  FLAGS = {
    :regular => {
      'en' => 'iVBORw0KGgoAAAANSUhEUgAAABYAAAAQCAYAAAAS7Y8mAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDQksgOwX6QAAAGNJREFUOMvNk8EJgEAMBCeHrdmN5aSG9GQ16+d8m8gFHQj7CWEZ7gxcFBHH484AiNipZBIXuCLOVIIrA5Wjdwoe513j7OFy46yK/zRuc/zlq7Cun2ez9nJsil7OoImNHhN9Ki7/2sdToHNltwAAAABJRU5ErkJggg==',
      'es' => 'iVBORw0KGgoAAAANSUhEUgAAABYAAAAQCAYAAAAS7Y8mAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDQg4gy3y1QAAAOlJREFUOMvtlMtqwmAQhb8/iVoJBFMIaBGx1K7Uhau68yV8Gd/Ap+qq2EXfwAtKaaiI2BLxktQ4LrS7bDTNQuiB2QzDN3DmMKpnloQEpJGQrg+s5AWJXPe7cn+qM2VEdb4WGaafN4gIhcIW+zaAMA5YgeeBO1C8PoMo4akFeg2sbEyPx98lvHcdf2FSbHYwHtoMZ8UYx1MQBvAzruD2LUY4zFcO62kFf3LPLjjOXGSFCGRyOvnGmrveDO+ti/g+2XIV2V/qsYCWUnxYW5xQeKybpJcGKXuOa2+opzXOoUfH7S9y/P8rEgcfANn7TQ48Ym1lAAAAAElFTkSuQmCC',
      'fr' => 'iVBORw0KGgoAAAANSUhEUgAAABYAAAAQCAYAAAAS7Y8mAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDQkSQY0KQgAAACtJREFUOMtjZAhd8p8BB/i/KpoBH/jgZIZTjomBRmDU4FGDRw0eNXh4GgwAw6cFhNyK6hIAAAAASUVORK5CYII=',
      'pt-BR' => 'iVBORw0KGgoAAAANSUhEUgAAABYAAAAQCAYAAAAS7Y8mAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDQgcvy4WBAAAAxNJREFUOMu1lF9oW2UYxn/fd87JSROTdjFmtnZtbPonSNdpMmztLGM6pht4ISKKV85b2SoDFYRhYeBFBS2FXiiIIOLNENxFZaIXohdj6DIq6/+l3TJi165N1tYuJ8k53+dFa2+slA18r9/3x8v7Ps8jGD6s+R/K3LVDGdjS4936m0g0gwvNOMoE6T0gWAtQBn21KwwnpnmyrgTAK7FF+uc6+PludBMu9H2APYM6q8KH8VlO7c0zfu1RPpt8AoCe5J/81DnGyJ0GBnItFKs+MLxdwFqCEry0Z4nBeJa4W+H0uROM/tpB1bUQAizL48ShGT45c5EX9xd570aCC8UYoEGqbZTB8fjA5pYmjb4SQ80zDDbNE/W5vD/yMqOXUtSGFEI54DoIFGOzjcwv1PHm8+O8Hlmixb5H5l6I1aoNUm+BX2gZQAveiuX5umWCw+E1lIZb612M26dp7w6Q7ovz7NEkDZ11+GssivllJq4/zNNdeZr3rXHAv8FrkSXWtSSzEQItMfcH/mKoaZbnwnfRCsoe2AH44UKAb768ilSr2H6TYNimKRml68g+uo418v0XOS5fjdHXc4uyA/Vmhc/jM7wRWeSdXBumJRTBLels/1dA2fEoO1VCQYlSmtVCibFfcvz24xxtqRjHTqZJRa+gnCvbswIISg9LaGRmI8yhyRT9N1tZ8UxsA3DhQHKRYFDir7HxPIXtNwmEfFh+g7k/lrk4kqE+MIOUYBtQ9EzO5BL0TqX5fSOMRCo8BMO3m+mdTHO+EAUP+p7K8UznOMtFHz7bolJ2casewaAfo+YRUm3XaI2MgYZvC1F6p9J8uhDH1QKk2lKFAKSiUPVxvrCXaSfAwfAar3ZfZ2q+lolshFLZxHEMlDY4cnCaj099x7Lf4O25ds7mE6y41qaexT/X3CkrPJOYr8RH8Swn9yxyOdPEpYnHAOhO5ulJ5/hqNcYH863crtSA4f4LIf4zhLbMcjxyh6HENO2hCgDZdYv+bAejhdimZoXacVzsmm6ewUNmlbMNN5Bozi08zlrV2tHG9wd+wPobcyQv6o3XrQAAAAAASUVORK5CYII=',
      'zh-CN' => 'iVBORw0KGgoAAAANSUhEUgAAABYAAAAQCAYAAAAS7Y8mAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAADpSURBVDiN7ZJBSgMxFIa/l4zTdhzbCnYrCG48gODGlStv4MKj6QGk9BLewa2VgttqB8ExIXnupljb6KDLfrsk//vyByKPJ0MlhQFiMrFx7OtGsbxn5zCwf123t66K86NAeeGatZ9ZFuMO2ShiB+mHrZIBiIHBVU157jGlkh8HXm57hEqI70Jx5nFTS1jYdo01wutdF7On2GGkmnQIlTSht/sc9/R7adMYIDuIzG+6+GeLHUWYLUX9yw/c1FI/ZGsl65DUrzC7iukrYS6goE42Rb/PJg97SnHqUSetpPBD47+QbLwVb8X/yycq9EgSCYo6ywAAAABJRU5ErkJggg=='
    },
    :small => {
      'en' => 'iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDRI3o78VnwAAADhJREFUKM9jWL36zn8Ghin/8dFnGBgwMAMhTQwMU/5jAwyjNuK2kfH/////GcgAjFD3kq6R7jYCAH96Ai929AYNAAAAAElFTkSuQmCC',
      'es' => 'iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDRIizmLxdAAAAJhJREFUKM/VkUEKgmAUhL/3Z0hqBknQquN0ju7WDTpDFNGuRZB4BCGz+gM1XwuhXRbumuU8hnkfIxt/pnSQoaM6B0XXNK8K1GqwD8Fzn5geoN8aBUrgdHBYLSfESUipjd8eNGDziON2TFrNyXTBJR22grxPRenhTgPq8w4b76kk/IFRIC98rneHOnMwg4IgUkb920dO+Z8dXxIiM+KRulROAAAAAElFTkSuQmCC',
      'fr' => 'iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDRItXt3s5QAAACRJREFUKM9jZAhd8p8BDfxfFY3C/+Bkhq6EgYmBTDCqcYRrBADrCAV6COJ14QAAAABJRU5ErkJggg==',
      'pt-BR' => 'iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QQEDRIS6LvB2AAAAaZJREFUKM+dks1LVGEUh5/3vbfJmdG54Pcwlo6ihKRDUrQoEFGh/KgW/QEtqo1uhBauTJT2YS6iTStXbiJIaKMUbkQQRL0qF1IZuybiqAM2zHjv+7pw+kBp0291+HHO5jyPYKxV8x+RFxolQQueRrd5Ft0GLc66czH/jAI8g4ZImpGKDRIpAQg665YZ+hFnLR0B0wf0X4fKQAhFX2yLgSKXsTcdDM7W4Z34PLzzjakX07yORBnfuYLSBkgfQ96LD98sTPM+vkp/zGXW7mFm9wGJlmIqa4v4ulBG4PiIV91L3L18yFo2yE6uALMxeMyn+kXKCjxQ8OHjJZbmHZKWojRWyK3OSrzy2+ifc7QXHzIVWqRt/QbSzoTpdZqZPrAgAE01LrmTANmMx9Zqii+TSWqtDUQQZg4sepwEK5kwhu6qHv6eDTGxX0EqZ/KkyeHIDWNvliCkyeNWh0f3PzO6V03/ZgPJXAgtNeI3Ry3AN7iW/+r1fYnWYJcqXu7WYKctMHwQOs/gvABKgtA8jyWRaN66V0EJkOpfHH8pcbbwzq3KFxrkRblOAYcXmiOyRv9QAAAAAElFTkSuQmCC'
    }
  }

  SVGS = {
    'en' => 'flags/estados-unidos.svg',
    'es' => 'flags/espanha.svg',
    'fr' => 'flags/franca.svg',
    'pt-BR' => 'flags/brasil.svg',
    'zh-CN' => 'flags/china.svg',
    'it' => 'flags/italia.svg',
    'de' => 'flags/alemanha.svg'
  }
end
