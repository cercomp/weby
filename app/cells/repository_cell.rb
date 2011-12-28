class RepositoryCell < Cell::Rails
  include ActionView::Helpers::TagHelper

  cache :include_one_file
  cache :include_many_files

  def include_one_file(name, label, args = {})
    get_params(name, label, args)

    @file = Repository.find(args[:object]) if args[:object]
    @image_label = tag("img", src: @file.archive.url(:mini)) if @file

    render 
  end

  def include_many_files(name, label, args = {})
    get_params(name, label, args)

    @files = Repository.
      where(id: [args[:object]].flatten.compact).
      page(1).per(9999) if args[:object]

    render
  end

  private
  def get_params(name, label, args = {})
    @name = name
    @label = label
    @final_files_list = @label.parameterize("_")

    @file_types = [args[:file_types]].flatten.compact
  end
end
