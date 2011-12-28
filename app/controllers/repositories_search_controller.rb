class RepositoriesSearchController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :load_data
  before_filter :check_authorization

  respond_to :html, :xml, :js

  def open_file_search_box
    @title = params[:title] || t("add.param", param: t("file.other"))
  end

  def search
    @files = @site.repositories.
      description_or_filename(params[:search][:name]).
      content_file(params[:search][:type]).
      page(params[:page]).per(24)
  end

  def include_files
    @files = Repository.
      where(id: params[:selected_files]).
      page(1)
    @label = @name.gsub(/(\]|\[)/, '_')

    if !@many
      @file = @files.first
      render template: 'repositories_search/include_one_file'
    else
      render template: 'repositories_search/include_many_files'
    end
  end

  private
  def load_data
    @many = params[:many] || false
    @name = params[:name]
    @final_files_list = params[:final_files_list]
    @file_types = [params[:file_types]].flatten
  end
end
