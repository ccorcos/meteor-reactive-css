# Define some styles
@styles = new ReactiveDict()
styles.set 'navHeightpx', 90
styles.set 'toolbarHeightpx', 50
styles.set 'contentMaxWidthem', 40

# reactive sizing
adjustSize = ->
  width = window.innerWidth
  height = window.innerHeight
  styles.set 'size.width', width
  styles.set 'size.height', height
  if width < 1200
    styles.set 'size', 'mobile'
  else
    styles.set 'size', 'desktop'

adjustSize()
window.addEventListener "resize", adjustSize

# React to Andoid vs iOS
ios = !!navigator.userAgent.match(/iPad/i) or !!navigator.userAgent.match(/iPhone/i) or !!navigator.userAgent.match(/iPod/i)
android = navigator.userAgent.indexOf('Android') > 0

styles.set 'platform', do ->
  if ios then return 'ios'
  if android then return 'android'
  return 'desktop'

# Using D3 to define an HCL color interpolation
@color = d3.scale.linear()
  .domain([0,1])
  .range(["#F3F983", "#373A49"])
  .interpolate(d3.interpolateHcl);

# @color = d3.scale.linear()
#   .domain([0,1])
#   .range(["#4D261F","#573649","#395267","#206B5D","#5E793B","#A97839"])
#   .interpolate(d3.interpolateHcl);

# Rotate the color scheme with a reactive var and a setInterval
@rotate = new ReactiveVar(0.0)

desaturate = (x) ->
  c = d3.hcl(x)
  c.c *= 0.7
  return c.toString()

lighten = (x) ->
  c = d3.hcl(x)
  c.l /= 0.7
  return c.toString()

darken = (x) ->
  c = d3.hcl(x)
  c.l *= 0.7
  return c.toString()

Tracker.autorun ->
  r = rotate.get()
  styles.set 'primary',   color(2/6 + r)
  styles.set 'secondary', color(1/6 + r)
  styles.set 'tertiary',  color(0/6 + r)
  styles.set 'primary.text',   lighten(desaturate(color(0/6+r)))
  styles.set 'secondary.text', lighten(desaturate(color(0/6+r)))
  styles.set 'tertiary.text',  darken(desaturate(color(2/6+r)))

inc = 1/6/10
rotateColors = ->
  r = rotate.get()
  if r+inc+2/6 >= 1.0
    inc *= -1
  else if r+inc <= 0
    inc *= -1
  r += inc
  rotate.set(r)

Meteor.setInterval(rotateColors, '100')


# Define all the styles
css '*': css.boxSizing('border-box')

page = css('.page')
  .fp()
  .bg -> styles.get('tertiary')
  .c -> styles.get('tertiary.text')

nav = css('.nav')
  .w 100, 'pc'
  .h 'px',  -> styles.get('navHeightpx')
  .bg -> styles.get('primary')
  .c -> styles.get('primary.text')


title = nav.child('.title')
  .w 100, 'pc'
  .h styles.get('navHeightpx')
  .lineHeight styles.get('navHeightpx')
  .fontSize 2, 'em'
  .c -> styles.get('primary.text')

# Make this whole chunk reactive
# Android titles pull left, while iOS is centered
Tracker.autorun ->
  if styles.equals('platform', 'android')
    title
      .pl 10, 'px'
      .margin 'auto'
      .textAlign 'left'
  else
    title
      .margin '0 auto'
      .pl 0
      .textAlign 'center'

content = css('.content')
  .position 'absolute'
  .top -> styles.get('navHeightpx')
  .pt 10, 'px'
  .bottom 'px', -> 
    if styles.equals('size','mobile')
      return styles.get('toolbarHeightpx')
    else
      return 0
  .pb 10, 'px'
  .pl 10
  .pr 10
  .left 0
  .right 0
  .overflowY 'scroll'
  .maxWidth 'em', -> styles.get('contentMaxWidthem')
  .margin '0 auto'

toolbar = css('.toolbar')
  .position('absolute')
  .bg -> styles.get('secondary')
  .c -> styles.get('secondary.text')

# On a larger layout, pull the toolbar to the left
Tracker.autorun ->
  device = styles.get('size')
  if device is 'mobile'
    toolbar
      .bottom 0
      .height styles.get('toolbarHeightpx')
      .left 0
      .right 0
      .top 'auto'
      .w 100, 'pc'
  else
    toolbar
      .height 'auto'
      .left "calc(50% - #{styles.get('contentMaxWidthem')/2}em - 210px)"
      .right 'auto'
      .width 200
      .top styles.get('navHeightpx') + 10
      .bottom styles.get('toolbarHeightpx')
