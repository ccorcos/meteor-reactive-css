# Rotate about the cubehelix
@rotate = new ReactiveVar(0.0)

# cubehelix = d3.scale.cubehelix()
cubehelix = d3.scale.cubehelix().range([d3.hsl(270, .75, .35), d3.hsl(70, 1.5, .8)])

cube = (x) ->
  r = rotate.get()
  v = (r+x) % 1.0
  # if v > 1.0 then v = 2.0 - v
  return cubehelix(v)

# Theme
@themes = new ReactiveDict()
Tracker.autorun ->
  themes.set 'dark.background', cube 0.3 #'#151515'
  themes.set 'dark.foreground', cube 0.1 #'#0c0c0c'
  themes.set 'dark.text',       cube 0.8 #'#dddddd'
  themes.set 'dark.primary',    cube 0.4 #'#4d91ea'
  themes.set 'dark.secondary',  cube 0.5 #'#8ee478'
  themes.set 'dark.tertiary',   cube 0.6 #'#cf0033'


# App Parameterized Styles
@styles = new ReactiveDict()
styles.setDefault 'nav.heightpx', 90
styles.setDefault 'sidebar.widthem', 10


theme = (str) -> themes.get "dark.#{str}"
style = (str) -> styles.get str


css 
  '*': css.boxSizing('border-box')

css('html body')
  .fp()
  .c -> theme('text')
  .bg -> theme('background')
  .np()
  .nm()

css
  '.nav':
    'color': -> theme('primary')
    'backgroundColor': -> theme('foreground')
    'widthpc': 100
    'heightpx': -> style('nav.heightpx')
    '.title':
      'paddingLeftem': 0.5
      'paddingRightem': 0.5
      'lineHeightpx': -> style('nav.heightpx')
      'fontSizeem': 2.5

css
  '#slider':
    'position': 'absolute'
    'rightem': 1
    'leftem': 20
    'topem': 2.3

css
  '.content':
    'position': 'absolute'
    'toppx': -> style 'nav.heightpx'
    'bottom': 0
    'right': 0
    'leftem': -> style 'sidebar.widthem'
    'paddingem': 0.5
    'color': -> theme('tertiary')
    
@sidebar = css('.sidebar')
  .pr(0.7, 'em').pl(0.7, 'em')
  .w 'em', -> style('sidebar.widthem')
  .position 'absolute'
  .top 'px', -> style 'nav.heightpx'
  .bottom 0
  .left 0

item = sidebar.child('.item').borderRadius('0.5em').rules
  'color': -> theme('background')
  'backgroundColor': -> theme('secondary')
  'height': '2em'
  'lineHeight': '2em'
  'textAlign': 'center'
  'fontSizeem': 1.25
  'margin': '1em 0em'


Template.main.rendered = ->
  $("#slider").noUiSlider({
    start: 0.0,
    range: {
      'min': 0.0,
      'max': 1.0
    }
  }).on 'slide', (x) ->
    rotate.set(parseFloat($(this).val()))

