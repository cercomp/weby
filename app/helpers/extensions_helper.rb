module ExtensionsHelper
  # Search for the availables extensions ordering by the I18N name
  def available_extensions_sorted
    #['teachers', 'feedback']
    Weby::extensions.map{|name,extension| [t("extensions.#{extension.name}.name"), extension.name]}
  end
end
