module ApplicationHelper

  def current_school
    current_ability.schools.try :first
  end

  # Adds given files to end of body tag
  def javascript(*files)
    content_for(:body_end) { javascript_include_tag(*files) }
  end

  def li(controller,current_controller)
    opts = {}
    opts = opts.merge(class: 'active') if controller == current_controller
    content_tag :li, opts do
      yield
    end
  end

  ##
  # Returns t('monthly_stat.description.stat_name') or nil if not found
  # @param [String] name
  # @return [String]
  def monthly_stat_description(name)
    begin
      I18n.translate("monthly_stat.description.#{name}", raise: true) 
    rescue I18n::MissingTranslationData
      nil
    end
  end

end
