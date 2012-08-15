module ApplicationHelper

  def li(controller,current_controller)
    opts = {}
    opts = opts.merge(class: 'active') if controller == current_controller
    content_tag :li, opts do
      yield
    end
  end

end
