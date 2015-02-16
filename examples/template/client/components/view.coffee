
Template.view.created = ->
  # global style parameters
  @styles = new ReactiveDict()
  @styles.set 'nav.height', 49
  @styles.set 'nav.fontSize', 24
  @styles.set 'nav.textColor', 'white'
  @styles.set 'nav.backgroundColor', 'red'
  @styles.set 'nav.statusBar.height', 10
  @styles.set 'content.padding', 10
  @styles.set 'content.textColor', 'black'
  @styles.set 'content.backgroundColor', 'white'

  @CSS = css('.view')
    .position('absolute')
    .top(0)
    .bottom(0)
    .left(0)
    .right(0)
  window.view = @

Template.view.destroyed = ->
  @CSS.stop()
  @styles.stop()