class RepositoryCell < Cell::Rails
  include ActionView::Helpers::TagHelper

  def include_file(name, label, args = {})
    @name = name
    @label = label
    @final_files_list = @label.parameterize("_")

    @multiplicity = args[:multiplicity] || "other"
    @file_types = [args[:file_types]].flatten.compact
    @same_place = args[:same_place].to_s || 'false'
    @repository_ids = [args[:object]].flatten.compact

    remake_label

    render
  end

  private
  def remake_label
    if @multiplicity != "other" && @repository_ids.length == 1 
      @image_label = tag("img", src: Repository.find(@repository_ids.first).archive.url)
    end
  end

end
