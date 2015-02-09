
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

