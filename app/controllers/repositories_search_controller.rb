class RepositoriesSearchController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization
  before_filter :load_data

  respond_to :html, :xml, :js

  def open_file_search_box
    @title = params[:title] || t("add.param", param: t("file.#{@multiplicity}"))
  end

  def search
    @files = @site.repositories.
      description_or_filename(params[:search][:name]).
      content_file(params[:search][:type])
  end

  def include_files
    @s = params[:selected_files]
    @files = Repository.where(id: params[:selected_files])
  end

  private
  def load_data
    @name = params[:name]
    @multiplicity = params[:multiplicity]
    @final_files_list = params[:final_files_list]
    @file_types = [params[:file_types]].flatten
  end
end
