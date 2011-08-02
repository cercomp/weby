module FormsHelper
  def images_radio(images, form, id)
    form.radio_button_group id, 
      images.map { |u|
      if File.file?(u.archive.path) and not File.file?(u.archive.path(:mini)) and u.image?
        u.archive.reprocess! 
      end
      { 
        :value => u.id,
        :image => u.archive.url(:mini),
        :alt => u.description,
        :title => u.description 
      }
    }, 
      (paginate images),
      :label => t("picture"),
      :help => t("picture")
  end

  def pages_radio(form, id)
    form.radio_button_group id,
      @pages.map { |u| 
      {
        :value => u.id,
        :label => u.title[0,50] + ((u.title.size > 50) ?  "..." : "")
      }
    },
      (paginate @pages),
      :label => t("url"),
      :help => t("url") 
  end

  def repos_radio(form, id, repo_styles)
    form.radio_button_group id,
      repo_styles.map { |u| 
      {
        :value => u[0],
        :label => "#{t(u[0])} #{u[1]}"
      }
    },
      "",
      :label => t("size"),
      :help => t("size")
  end
end
