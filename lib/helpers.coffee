# Helpers
css.mixin 'fullPage', ->
  position: 'absolute'
  top: 0
  bottom: 0
  left: 0
  right: 0

css.mixin 'noPadding', ->
  paddingTop: 0
  paddingBottom: 0
  paddingLeft: 0
  paddingRight: 0

css.mixin 'noMargin', ->
  marginTop: 0
  marginBottom: 0
  marginLeft: 0
  marginRight: 0


css.mixin 'fullWidth', -> {width: '100%'}
css.mixin 'fullHeight', -> {height: '100%'}

css.alias('fullPage', 'fp')
css.alias('fullWidth', 'fw')
css.alias('fullHeight', 'fh')
css.alias('fullPage', 'fp')
css.alias('noMargin', 'nm')
css.alias('noPadding', 'np')

