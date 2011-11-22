class RepositoryCell < Cell::Rails

  def include_file(name, label, args = {})
    @name = name
    @label = label
    @final_files_list = @label.parameterize("_")

    @multiplicity = args[:multiplicity] || "other"
    @file_types = args[:file_types] || []

    render
  end

end
