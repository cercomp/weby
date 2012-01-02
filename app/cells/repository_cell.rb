class RepositoryCell < Cell::Rails
  def include_one_file(name, label, site, args = {})
    get_params(name, label, site, args)

    @file = Repository.find(args[:object]) if args[:object]
    @image_label = tag("img", src: @file.archive.url(:mini)) if @file

    render 
  end

  def include_many_files(name, label, site, args = {})
    get_params(name, label, site, args)

    @files = Repository.
      where(id: [args[:object]].flatten.compact).
      page(1).per(9999) if args[:object]

    render
  end

  private
  def get_params(name, label, site, args = {})
    @name = name
    @label = label
    @site = Site.find(site).name
    @final_files_list = @label.parameterize("_")

    @file_types = [args[:file_types]].flatten.compact
  end
end
