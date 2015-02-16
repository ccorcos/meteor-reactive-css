Template.nav.created = ->

  view = @getParentNamed('view')

  @navCSS = css('.nav')
    .position('absolute')
    .top(0).left(0).right(0)
    .textOverflow('ellipsis')
    .height(-> view.styles.get('nav.height'))
    .lineHeight( -> view.styles.get('nav.height') - view.styles.get('nav.statusBar.height'))
    .pt( -> view.styles.get('nav.statusBar.height'))
    .fontSize( -> view.styles.get('nav.fontSize'))
    .textAlign('center')
    .color( -> view.styles.get('nav.textColor'))
    .bg( -> view.styles.get('nav.backgroundColor'))

  @leftCSS = @navCSS.child('.left')
    .position('absolute')
    .top(-> view.styles.get('nav.statusBar.height'))
    .left(0)
    .height( -> view.styles.get('nav.height') - view.styles.get('nav.statusBar.height'))
    .pl( -> view.styles.get('content.padding'))

  @rightCSS = @navCSS.child('.right')
    .position('absolute')
    .top(-> view.styles.get('nav.statusBar.height'))
    .right(0)
    .height( -> view.styles.get('nav.height') - view.styles.get('nav.statusBar.height'))
    .pr( -> view.styles.get('content.padding'))


Template.nav.destroyed = () ->
  @navCSS.stop()
  @leftCSS.stop()
  @rightCSS.stop()


