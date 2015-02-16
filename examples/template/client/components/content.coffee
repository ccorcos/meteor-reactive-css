

Template.content.created = ->

  view = @getParentNamed('view')

  @CSS = css('.content')
    .position('absolute')
    .top( -> view.styles.get('nav.height'))
    .bottom(0)
    .left(0)
    .right(0)
    .color( -> view.styles.get('content.textColor'))
    .bg( -> view.styles.get('content.backgroundColor'))
    .padding( -> view.styles.get('content.padding'))

Template.content.destroyed = ->
  @CSS.stop()
