# Reactive CSS

This package allows you to define all your CSS rules in a Javascript or Coffeescript and with reactive bindings to Tracker-aware functions.

Check out the [live demo](http://reactive-css.meteor.com). It demonstrates:

- reactive-responsive deisgn: changes layout when window resizes
- reactively updating color scheme
- platform-specific css for Android vs iOS

## Getting Started

    meteor add ccorcos:reactive-css

The API is highly flexible so choose whatever syntax works best for you.

### Basics

The easiest way to get started is by defining nested rules they way you are probably comfortable with in whatever CSS preprocessing language you use.

    css
      '.page':
        '.nav':
          'height': '90px'
          'width': '100%'
        '.content':
          'paddingTop': '90px'
          'paddingBottom': '50px'
          'color': 'blue'
          '&:hover':
            'color': 'red'
        '.toolbar':
          'height': '50px'


The other way is more object oriented.

    page = css('.page')
    
    nav = page.child('.nav').height('90px').width('100%')
    
    content = page.child('.content')
    content.paddingTop('90px')
    content.paddingBottom('20px')
    content.color('blue')
    
    hoveredContent = content.also(':hover')
    hoveredContent.color('red')

    toolbar = page.child('.toolbar').height('50px')

Every function returns `this` so you can chain them, or not.

### Units

Units are handled in a few ways. For nested objects, it is sometimes convenient to leave everything as numbers so you can add and subtract them. Thus you can specify the unit by the postfix 2 letters in the CSS rule. For example:

    navHeightpx = 90
    toolbarHeightpx = 50
    css
      '.page':
        '.nav':
          'heightpx': navHeightpx
          'widthpc': 100
        '.content':
          'paddingToppx': navHeightpx
          'paddingBottompx': toolbarHeightpx
          'color': 'blue'
          '&:hover':
            'color': 'red'
        '.toolbar':
          'heightpx': toolbarHeightpx

Valid postfixes are 'px', 'pc', 'vh', 'vw', and 'em'.

The object oriented way is to pass a second string for the units.

    page = css('.page')
    
    nav = page.child('.nav').height(navHeightpx, 'px').width(100, 'pc')
    
    content = page.child('.content')
    content.paddingTop(navHeightpx)
    content.paddingBottom(toolbarHeightpx)
    content.color('blue')
    
    hoveredContent = content.also(':hover')
    hoveredContent.color('red')

    toolbar = page.child('.toolbar').height(toolbarHeightpx)

The defualt unit is 'px' so you don't necessarily have to specify it.

### Reactivity

This package is "Tracker-aware". So if you pass a function, it will evaluate the function with `Tracker.autorun`. This allows you to reactively update CSS rules! Suppose you parameterize your whole app within a reactive dictionary:

    styles = new ReactiveDict()
    styles.set('primary', 'blue')
    styles.set('background', 'white')
    styles.set('navHeightpx', 90)
    styles.set('toolbarHeightpx', 50)

Then for the nested object you could use:

    css
      '.page':
        '.nav':
          'backgroundColor': -> styles.get('primary')
          'heightpx': -> styles.get('navHeightpx')
        '.content':
          'paddingToppx': -> styles.get('navHeightpx')
          'paddingBottompx': -> styles.get('toolbarHeightpx')
          'backgroundColor': -> styles.get('background')
        '.toolbar':
          'backgroundColor': -> styles.get('primary')
          'heightpx': -> styles.get('toolbarHeightpx')

The object oriented way is the same idea, only the units will be the first arguement as opposed to the second. This makes your coffeescript a lot nicer :)

    page = css('.page')
    
    nav = page
      .child '.nav'
      .height 'px', -> styles.get('navHeightpx')
      .backgroundColor -> styles.get('primary')

    content = page
      .child '.content'
      .paddingTop 'px', -> styles.get('navHeightpx')
      .paddingBottom 'px', -> styles.get('toolbarHeightpx')
      .backgroundColor -> styles.get('background')

    toolbar = page
      .child '.toolbar'
      .height 'px', -> styles.get('toolbarHeightpx')
      .backgroundColor -> styles.get('primary')

### Mixins

This library is clearly incomplete and it would be concenient if you could extend it nicely. Mixins attach to the css object AND the css prototype. Here's how you define one:

    css.mixin 'fullPage', ->
      position: 'absolute'
      top: 0
      bottom: 0
      left: 0
      right: 0

    css.mixin 'boxSizing', (args...) ->
      obj = {}
      value = args.join(' ')
      obj['boxSizing'] = value
      obj["Webkit"+capitalize('boxSizing')] = value
      obj["Moz"+capitalize('boxSizing')] = value
      obj["Ms"+capitalize('boxSizing')] = value
      return obj

    css.mixin 'borderRadius', (args...) ->
      obj = {}
      # args could be [10, 'em']
      value = args.join(' ')
      obj['borderRadius'] = value
      obj["Webkit"+capitalize('borderRadius')] = value
      obj["Moz"+capitalize('borderRadius')] = value
      obj["Ms"+capitalize('borderRadius')] = value
      return obj

This allows you to add vendor prefixes as you like as well as create convenient helpers which you could use in a few ways:

    css '*': css.boxSizing('border-box')

    css
      '.page': _.extend css.fullPage(),
        '.nav':
          'backgroundColor': -> styles.get('primary')
          'heightpx': -> styles.get('navHeightpx')

    page = css('.page').fullPage()

Now, all that typing can be a pain, especially 'backgroundColor'. So there's an alias function to alias mixins.

    css.alias('backgroundColor', 'bg')

Ahh... Much better. No help me expand this package! Or build a responsive framework using [reactive window size](https://github.com/gadicc/meteor-reactive-window)! Create different styles easily whether on Android or iOS. Or, as in the demo, create a rotating color scheme for your app!

## Pros and Cons

There is obviously going to be a tradeoff here. So lets enumerate them.

Pros

- Create your CSS styles using a turing complete language you are familiar with.
- Reactively update your CSS styles.

Cons

- Browsers cannot cache your CSS stylesheets. 
- `Tracker.autorun` everywhere, but wait, you don't have to use it.

I think its worth it. I hate "battling the framework" when it comes to CSS.

## To Do
- tests
- template-specific css using `Template.name.css(...)`. maybe give every template a class?