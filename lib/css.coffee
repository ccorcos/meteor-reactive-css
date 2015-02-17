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
  idx = _.map(@sheet.cssRules, (rule) -> rule.selectorText).indexOf(selector)
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
  else if ending is 'vh'
    key = key[0...-2]
    value = "#{value}vh"
  else if ending is 'vw'
    key = key[0...-2]
    value = "#{value}vw"

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
  # safeguard so you dont have to use new
  if not (this instanceof css) then return new css(input)
  @autoruns = []
  if isString(input)
    @selector = input
    return this
  else if isPlainObject(input)
    @nested(input)
    return
  else
    console.log "WARNING CoffeeCSS: calling css() doesn't do anything.", input
    return

# Recursively parse a nested object of CSS rules
css::nested = (obj, selector="") ->
  self = this
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
      nextSelector = ""
      if selector is ""
        nextSelector = key
      else if key[0] is '&'
        nextSelector = "#{selector}#{key}"
      else
        nextSelector = "#{selector} #{key}"
      @nested(value, nextSelector)

    else if isFunction(value)
      do (key, value) ->
        self.autoruns.push Tracker.autorun -> 
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
    @autoruns.push Tracker.autorun -> 
      rule(self.selector, name, value())  
  else
    rule(@selector, name, value)
  return this

css::rules = (obj) ->
  @nested(obj, @selector)

css::stop = ->
  for autorun in @autoruns
    autorun.stop()
  return

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
      @autoruns.push Tracker.autorun ->
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