class RepositoryCell < Cell::Rails

  def include_file(name, label, args = {})
    @name = name
    @label = label
    @final_files_list = @label.parameterize("_")

    @multiplicity = args[:multiplicity] || "other"
    @file_types = [args[:file_types]].flatten
    @same_place = args[:same_place].to_s || 'false'

    render
  end

end
