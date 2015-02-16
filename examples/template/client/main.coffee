Blaze.TemplateInstance.prototype.getParentNamed = (name) ->
  template = this
  while template
    if name is template.view.name.split('.').splice(1).join('.')
      return template

    view = template.view.originalParentView or template.view.parentView
    
    while view and (not view.template or view.name is '(contentBlock)')
      view = view.originalParentView or view.parentView

    template = view.templateInstance?()

  return template