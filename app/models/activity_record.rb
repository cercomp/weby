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
          (activity_records.differences IS NOT NULL AND LOWER(CAST(activity_records.differences AS text)) LIKE :term) OR
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

  IGNORED_ATTRIBUTES = %w[
    id
    created_at
    updated_at
    encrypted_password
    crypted_password
    password_salt
    persistence_token
    perishable_token
    single_access_token
    reset_password_token
    confirmation_token
    unlock_token
    view_count
  ].freeze

  def differences
    has_attribute?(:differences) ? (super || {}) : {}
  end

  def has_differences?
    differences.present? && differences.is_a?(Hash) && differences.any?
  end

  def self.extract_changes(loggeable)
    return {} unless loggeable.is_a?(ActiveRecord::Base)

    diffs = {}

    # 1. Main model saved changes
    if loggeable.respond_to?(:saved_changes) && loggeable.saved_changes.present?
      loggeable.saved_changes.except(*IGNORED_ATTRIBUTES).each do |attr, (before_val, after_val)|
        next if before_val.blank? && after_val.blank?

        fmt_before = format_value_for_diff(loggeable, attr, before_val)
        fmt_after  = format_value_for_diff(loggeable, attr, after_val)
        next if fmt_before == fmt_after

        diffs[attr] = [fmt_before, fmt_after]
      end
    end

    # 2. Nested i18ns (translates / weby_content_i18n)
    if loggeable.respond_to?(:i18ns)
      i18n_records = loggeable.i18ns.select { |i| i.respond_to?(:saved_changes) && i.saved_changes.present? }
      multi_locale = (loggeable.respond_to?(:locales) && loggeable.locales.count > 1) || (loggeable.i18ns.size > 1)

      i18n_records.each do |i18n|
        ignored = IGNORED_ATTRIBUTES + %w[locale_id] + ["#{loggeable.class.name.demodulize.underscore}_id"]
        locale_name = i18n.locale.try(:name) || i18n.locale_id.to_s

        i18n.saved_changes.except(*ignored).each do |attr, (before_val, after_val)|
          next if before_val.blank? && after_val.blank?

          fmt_before = format_value_for_diff(i18n, attr, before_val)
          fmt_after  = format_value_for_diff(i18n, attr, after_val)
          next if fmt_before == fmt_after

          key = multi_locale ? "#{attr} (#{locale_name})" : attr
          diffs[key] = [fmt_before, fmt_after]
        end
      end
    end

    # 3. Association joins (e.g. news_sites, event_sites, banner_sites)
    [:news_sites, :event_sites, :banner_sites].each do |assoc|
      if loggeable.respond_to?(assoc)
        loggeable.send(assoc).each do |child|
          next unless child.respond_to?(:saved_changes) && child.saved_changes.present?

          ignored = IGNORED_ATTRIBUTES + %w[site_id journal_news_id banner_id event_id]
          child.saved_changes.except(*ignored).each do |attr, (before_val, after_val)|
            next if before_val.blank? && after_val.blank?

            fmt_before = format_value_for_diff(child, attr, before_val)
            fmt_after  = format_value_for_diff(child, attr, after_val)
            next if fmt_before == fmt_after

            diffs[attr] = [fmt_before, fmt_after]
          end
        end
      end
    end

    diffs
  end

  def self.format_value_for_diff(record, attr, value)
    return nil if value.nil?

    if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
      return value.strftime('%d/%m/%Y %H:%M')
    end

    if value.is_a?(Date)
      return value.strftime('%d/%m/%Y')
    end

    if attr.to_s == 'repository_id'
      if value.present? && value.to_i > 0
        repo = Repository.find_by(id: value)
        return repo ? "#{repo.archive_file_name.presence || repo.description.presence || repo.title} (##{value})" : "Arquivo ##{value}"
      else
        return nil
      end
    end

    if value.is_a?(Array)
      return value.reject(&:blank?).join(', ')
    end

    if value.is_a?(TrueClass) || value.is_a?(FalseClass)
      return value ? 'Sim' : 'Não'
    end

    value.to_s
  end

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
