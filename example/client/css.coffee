###
# Note
a = ->
  if not (this instanceof a) then return new a()
  @something = 10
  return this

a.f = -> 21
a::f = -> @something * 10

console.log a.f() # => 21
console.log a().f() # => 100
###

# Some helper functions
isFunction = (value) -> (typeof value is 'function')
isPlainObject = (value) -> (typeof value is 'object') and not Array.isArray(value)
isArray = (value) -> Array.isArray(value)
isString = (value) -> (typeof value == 'string')
isNumber = (value) -> (typeof value == 'number')
capitalize = (string) -> string and (string.charAt(0).toUpperCase() + string.slice(1))

# Create the Stylesheet in the DOM
Stylesheet = ->
  if not (this instanceof Stylesheet) then return new Stylesheet()
  @styles = {}
  style = document.createElement('style')
  style.setAttribute('media', 'screen')
  style.appendChild(document.createTextNode(''))
  document.head.appendChild(style)
  @sheet = style.sheet
  return this

# Add a CSS rule to the stylesheet
Stylesheet::rule = (selector, key, value) ->
  # check if the selector is already in the stylesheet
  idx = Array.map(@sheet.cssRules, (rule) -> rule.selectorText).indexOf(selector)
  # else make a new rule
  unless idx >= 0
    idx = @sheet.insertRule("#{selector} {}", 0)

  unless selector of @styles
    @styles[selector] = {}

  # check if the rule ends with px, pc, or em for translating values
  ending = key[-2..-1]
  if ending is 'px'
    key = key[0...-2]
    value = "#{value}px"
  else if ending is 'pc'
    key = key[0...-2]
    value = "#{value}%"
  else if ending is 'em'
    key = key[0...-2]
    value = "#{value}em"

  # write the rule
  # console.log "#{key}: #{value}" 
  @styles[selector][key] = value
  @sheet.cssRules[idx].style[key] = value

# EXAMPLE: Make a style sheet and add rules to it:
# stylesheet().rule('.page', 'widthpc', 100)

# Create a stylesheet for everything else to use
@stylesheet = Stylesheet()
rule = (args...) -> stylesheet.rule.apply(stylesheet, args)

# if input is a...
#   object: then parse out the nested CSS rules
#   string: set the selector and the prototype function create rules on that selector
@css = (input) ->
  if isString(input)
    # safeguard so you dont have to use new
    if not (this instanceof css) then return new css(input)
    @selector = input
    return this
  else if isPlainObject(input)
    css.nested(input)
    return
  else
    console.log "WARNING CoffeeCSS: calling css() doesn't do anything.", input
    return

# Recursively parse a nested object of CSS rules
css.nested = (obj, selector="") ->
  for key, value of obj
    # if its a string, then its a CSS rule
    # if its an object, then recursively update the selector
    # if its a function, run reactively
    if isString(value) or isNumber(value)
      if selector is ""
        console.log("WARNING CoffeeCSS: No selector in nested CSS object?!")
        return
      rule(selector, key, value)

    else if isPlainObject(value)
      if selector is ""
        selector = key
      else if key[0] is '&'
        selector = "#{selector}#{key}"
      else
        selector = "#{selector} #{key}"
      css.nested(value, selector)

    else if isFunction(value)
      do (key, value) ->
        Tracker.autorun -> 
          rule(selector, key, value())

    else
      console.log "WARNING CoffeeCSS: Not a valid CSS rule: #{selector} {#{key}: #{value}};"

# return a new css instance with the selector appended
css::child = (string) ->
  return css(@selector + " #{string}")

# return a new css instance with the selector appended
css::also = (string) ->
  return css(@selector + "#{string}")

# manual specification
# css('.page').rule('overflowX', 'scroll')
# => writes the rule, .page {overflow-x: scroll}
css::rule = (name, value) ->
  if isFunction(value)
    self = this
    # run the function in a reactive context
    Tracker.autorun -> 
      rule(self.selector, name, value())  
  else
    rule(@selector, name, value)
  return this

css::rules = (obj) ->
  css.nested(obj, @selector)


# define a method for creating mixins.
css.mixin = (name, func) ->
  css[name] = func
  css::[name] = (args...) ->
    last = args.length-1
    if isFunction(args[last])
      self = this
      # your first input can be a unit, with the second being the function
      # but we need to reverse them into the mixin function because we
      # typically just join the args.
      if args.length > 1
        args.unshift(args[last])
        args.pop()
      # run the function in a reactive context
      f = args[0]
      Tracker.autorun ->
        args[0] = f()
        obj = func.apply(self, args)
        for k, v of obj
          rule(self.selector, k, v)
    else
      obj = func.apply(@, args)
      for k, v of obj
        rule(@selector, k, v)

    return this

css.alias = (name, aliases...) ->
  for alias in aliases
    css[alias] = css[name]
    css::[alias] = css::[name]

# parse curried arguments for single units if necessary
# default px
argsToUnits = (args...) ->
  if args.length is 1
    value = args[0]
    if isString(value)
      return value
    else
      return "#{value}px"
  else if args.length is 2
    if args[1] is 'pc' then args[1] = '%'
    return "#{args[0]}#{args[1]}"

# simple meaning no units or anything to parse
simpleMixins = [
  'color'
  'backgroundColor'
  'position'
]

simplePrefixMixins = [
  'boxSizing'
  'userSelect'
  'opacity'
  'textAlign'
]

# one unit meaning theres only one posisble value input
# but it could be px, em, %, etc.
oneUnitMixins = [
  'height'
  'width'
  'paddingTop'
  'paddingBottom'
  'paddingRight'
  'paddingLeft'
  'marginTop'
  'marginBottom'
  'marginRight'
  'marginLeft'
  'top'
  'bottom'
  'left'
  'right'
  'lineHeight'
]

oneUnitPrefixMixins = [
  'borderRadius'
]

for name in simpleMixins
  do (name) ->
    css.mixin name, (args...) ->
      obj = {}
      value = args.join(' ')
      obj[name] = value
      return obj

for name in simplePrefixMixins
  do (name) ->
    css.mixin name, (args...) ->
      obj = {}
      value = args.join(' ')
      obj[name] = value
      obj["Webkit"+capitalize(name)] = value
      obj["Moz"+capitalize(name)] = value
      obj["Ms"+capitalize(name)] = value
      return obj

for name in oneUnitMixins
  do (name) ->
    css.mixin name, (args...) ->
      obj = {}
      obj[name] = argsToUnits.apply({}, args)
      return obj

for name in oneUnitPrefixMixins
  do (name) ->
    css.mixin name, (args...) ->
      obj = {}
      unit = argsToUnits.apply({}, args)
      obj[name] = unit
      obj["Webkit"+capitalize(name)] = unit
      obj["Moz"+capitalize(name)] = unit
      obj["Ms"+capitalize(name)] = unit
      return obj


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

# Create some aliases of the mixins :)
css.alias('color', 'c')
css.alias('backgroundColor', 'bg')
css.alias('height', 'h')
css.alias('width', 'w')
css.alias('paddingTop', 'pt')
css.alias('paddingBottom', 'pb')
css.alias('paddingLeft', 'pl')
css.alias('paddingRight', 'pr')
css.alias('marginTop', 'mt')
css.alias('marginBottom', 'mb')
css.alias('marginLeft', 'ml')
css.alias('marginRight', 'mr')


css.alias('noMargin', 'nm')
css.alias('noPadding', 'np')

css.alias('fullPage', 'fp')