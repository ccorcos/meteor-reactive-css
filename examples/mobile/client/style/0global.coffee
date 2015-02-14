# darker to lighter color scheme using HCL
scheme = ['#21313E', '#20575F', '#268073', '#53A976', '#98CF6F', '#EFEE69']
# scheme = d3.scale.linear()
#   .domain([0,1])
#   .range(["#21313E", "#EFEE69"])
#   .interpolate(d3.interpolateHcl)

@colors = 
  primary: scheme[0]
  primaryText: scheme[3]
  secondary: scheme[1]
  secondaryText: scheme[4]
  tertiary: scheme[2]
  tertiaryText: scheme[5]
  background: '#dddddd'
  backgroundText: '#222222'

@style = 
  statusBarHeight: 10
  navHeight: 49
  navFontSize: 24
  contentPadding: 10