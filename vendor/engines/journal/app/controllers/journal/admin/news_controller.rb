module Journal::Admin
  class NewsController < Journal::ApplicationController
    include ActsToToggle
    
    before_action :require_user
    before_action :check_authorization
    before_action :status_types, only: [:new, :edit, :create, :update, :index]

    respond_to :html, :js

    helper_method :sort_column

    def index
      @newslist = get_news
      respond_with(:admin, @newslist) do |format|
        if params[:template]
          format.js { render "#{params[:template]}" }
          format.html { render partial: "#{params[:template]}", layout: false }
        end
      end
    end

    def recycle_bin
      params[:sort] ||= 'journal_news.deleted_at'
      params[:direction] ||= 'desc'
      @newslist = Journal::News.where(site_id: current_site).trashed.includes(:user, :categories).
        order("#{params[:sort]} #{sort_direction}").
        page(params[:page]).per(params[:per_page])
    end

    def get_news
      case params[:template]
      when 'tiny_mce'
        params[:per_page] = 7
      end
      params[:direction] ||= 'desc'

      news = Journal::News.where(site_id: current_site).
        search(params[:search], 1) # 1 = busca com AND entre termos

      if sort_column == 'tags.name'
        news = news.includes(categories: :taggings)
      end
      if params[:status_filter].present? && Journal::News::STATUS_LIST.include?(params[:status_filter])
        news = news.send(params[:status_filter])
      end

      news = news.order(sort_column + ' ' + sort_direction).page(params[:page]).per(params[:per_page])
    end
    private :get_news

    # Essa action não chama o get_news pois não faz paginação
    def fronts
      @newslist = Journal::News.where(site_id: current_site.id).available_fronts.order('position desc')
    end

    def show
      @news = Journal::News.where(site_id: current_site).find(params[:id]).in(params[:news_locale])
      if request.path != admin_news_path(@news)
        redirect_to admin_news_path(@news, news_locale: params[:news_locale]), status: :moved_permanently
        return
      end
      respond_with(:admin, @news)
    end

    def new
      @news = Journal::News.new(site_id: current_site)
    end

    def edit
      @news = Journal::News.where(site_id: current_site).find(params[:id])
    end

    def create
      @news = Journal::News.new(news_params)
      @news.site = current_site
      @news.user = current_user
      @news.save
      record_activity('created_news', @news)
      respond_with(:admin, @news)
    end

    def update
      params[:news][:related_file_ids] ||= []
      @news = Journal::News.where(site_id: current_site).find(params[:id])
      @news.update(news_params)
      record_activity('updated_news', @news)
      respond_with(:admin, @news)
    end

    def status_types
      @status_types = Journal::News::STATUS_LIST.map { |el| [t("journal.admin.news.form.#{el}"), el] }
    end
    private :status_types

    def destroy
      @news = Journal::News.unscoped.where(site_id: current_site).find(params[:id])
      if @news.trash
        if @news.persisted?
          record_activity('moved_news_to_recycle_bin', @news)
          flash[:success] = t('moved_news_to_recycle_bin')
        else
          record_activity('destroyed_news', @news)
          flash[:success] = t('successfully_deleted')
        end
      else
        flash[:error] = @news.errors.full_messages.join(', ')
      end

      redirect_to :back
    end

    def recover
      @news = Journal::News.where(site_id: current_site).trashed.find(params[:id])
      if @news.untrash
        flash[:success] = t('successfully_restored')
      end
      record_activity('restored_news', @news)
      redirect_to :back
    end

    private

    def sort_column
      params[:sort] || 'journal_news.id'
    end

    def news_params
      params.require(:news).permit(:source, :url, :category_list, :date_begin_at,
                                   :date_end_at, :image, :status, :front,
                                   { i18ns_attributes: [:id, :locale_id, :title,
                                       :summary, :text, :_destroy],
                                     related_file_ids: [] })
    end
  end
end
