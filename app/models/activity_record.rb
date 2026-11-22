class ActivityRecord < ApplicationRecord
  belongs_to :loggeable, polymorphic: true, optional: true
  belongs_to :site, optional: true
  belongs_to :user

  scope :user_or_action_like, ->(text, site_id = nil) {
    if text.present?
      term = "%#{text.try(:strip).try(:downcase)}%"

      repo_ids = Repository.unscoped.where(
        "LOWER(archive_file_name) LIKE :term OR LOWER(description) LIKE :term OR LOWER(title) LIKE :term",
        term: term
      ).select(:id)

      page_ids = Page.unscoped.joins(:i18ns).where(
        "LOWER(page_i18ns.title) LIKE :term",
        term: term
      ).select(:id)

      news_ids = Journal::News.unscoped.joins(:i18ns).where(
        "LOWER(journal_news_i18ns.title) LIKE :term",
        term: term
      ).select(:id)

      relation = left_joins(:user).where(
        "(LOWER(users.first_name) LIKE :term OR
          LOWER(users.last_name) LIKE :term OR
          LOWER(users.login) LIKE :term OR
          LOWER(users.email) LIKE :term OR
          LOWER(activity_records.action) LIKE :term OR
          LOWER(activity_records.controller) LIKE :term OR
          LOWER(activity_records.note) LIKE :term OR
          LOWER(activity_records.params) LIKE :term OR
          (activity_records.loggeable_type = 'Repository' AND activity_records.loggeable_id IN (:repo_ids)) OR
          (activity_records.loggeable_type = 'Page' AND activity_records.loggeable_id IN (:page_ids)) OR
          (activity_records.loggeable_type = 'Journal::News' AND activity_records.loggeable_id IN (:news_ids)))",
        term: term, repo_ids: repo_ids, page_ids: page_ids, news_ids: news_ids
      )
      relation = relation.where(site_id: site_id) if site_id.present?
      relation
    end
  }

  scope :by_controller, ->(ctrl) { where(controller: ctrl) if ctrl.present? }
  scope :by_action_name, ->(act) { where(action: act) if act.present? }
  scope :by_user_id, ->(uid) { where(user_id: uid) if uid.present? }

  scope :by_date_range, ->(start_d, end_d) {
    rel = all
    if start_d.present?
      begin
        d = start_d.include?('/') ? Date.strptime(start_d, '%d/%m/%Y') : Date.parse(start_d)
        rel = rel.where('activity_records.created_at >= ?', d.beginning_of_day)
      rescue ArgumentError, Date::Error
      end
    end
    if end_d.present?
      begin
        d = end_d.include?('/') ? Date.strptime(end_d, '%d/%m/%Y') : Date.parse(end_d)
        rel = rel.where('activity_records.created_at <= ?', d.end_of_day)
      rescue ArgumentError, Date::Error
      end
    end
    rel
  }

  def is_linkable?
    (action != "destroy" || note.to_s.match(/reseted/)) && loggeable_id.present? && loggeable_type.present? && loggeable.present?
  end

  def item_deleted?
    loggeable_id.present? && loggeable.nil?
  end

  def target_title
    if loggeable.present?
      if loggeable.is_a?(Repository)
        loggeable.archive_file_name.presence || loggeable.description.presence || loggeable.title
      elsif loggeable.respond_to?(:title) && loggeable.title.present?
        loggeable.title
      elsif loggeable.respond_to?(:screen_name)
        loggeable.screen_name
      elsif loggeable.respond_to?(:name)
        loggeable.name
      else
        "#{loggeable_type} ##{loggeable_id}"
      end
    else
      # Tenta extrair nome/descrição dos parâmetros gravados
      extract_title_from_params || "#{loggeable_type || controller.to_s.singularize.camelize} ##{loggeable_id}"
    end
  end

  private

  def extract_title_from_params
    return nil if params.blank?

    # Nome original de arquivo no upload
    if params =~ /@original_filename="([^"]+)"/
      return Regexp.last_match(1)
    end
    # Descrição do arquivo / repositório
    if params =~ /"description"=>"([^"]+)"/
      return Regexp.last_match(1)
    end
    # Título de página ou notícia
    if params =~ /"title"=>"([^"]+)"/
      return Regexp.last_match(1)
    end
    # Nome
    if params =~ /"name"=>"([^"]+)"/
      return Regexp.last_match(1)
    end
    nil
  end

end
