# Java(Coffee)Script CSS

Highly work in progress

## To Do
- README about the API
- why no black or white?
- npm AND meteor?
- how to write tests

- make a meteor example
- viewport height and width units

- make some examples
  - color scheme rotations
  - responsive design
  - platform-specific design


## Thoughts
- no need to bind to template but could still be used to make components

##Syntax

### Basics

1. plain nested objects object:
    
    Right off the bat, we get nested classes just like SCSS or LESS.

        css
          '.page':
            '.nav':
              height: '90px'
            '.content':
              paddingTop: '90px'

2. Parameterize with units

    Any CSS rule can be postfixed by 'px', 'pc' (percent), or 'em' to 
    specify units. This way you can parameterize your CSS.

        navHeight = 90

        css
          '.page':
            '.nav':
              heightpx: navHeight
            '.content':
              paddingToppx: navHeight

3. Make your CSS reactive!

    You can make any CSS rule reactive by passing function that
    depends on a reactive variable.

        navHeight = new ReactiveVar(90)

        css
          '.page':
            '.nav':
              heightpx: -> navHeight.get()
            '.content':
              paddingToppx: -> navHeight.get()

4. Just like LESS and SCSS, you can prefix with '&' to attach to the previous selector.

### Advanced / Brainstorming

1. You can chain rules together using `css.chain().something().somethingElse().value()`

    There are a variety of Mixins and helpers on the `css` function for prefixing or just syntactic sugar.

        css '.element': css.chain().color(-> theme.get('primary')).bg(-> theme.get('background')).fullWidth().height(100, 'px').value()

    You can use _.extend to make even better use of helpers and mixins.

        css 
          '.element': _.extend css.borderRadius(10, 'px'),
            fontSize: '10px'

2. What if everything was chained just like d3?

        styles = new ReactiveDict()
        styles.setDefault 'nav.height', 90

        style = (x) -> -> styles.get(x)

        page = css('.page')
        page.child('.nav').height(style('nav.height'))
        page.child('.content').paddingTop(style('nav.height'))
        page.also('.disconnected').color('yellow')

    I like this -- its a lot more verbose.

3. Whats the best way to deal with units?

    - postfix the attribute name: 'heightpx'
    - optionally pass an array: [90, 'px']
    - optionally pass a second argument: .height(90, 'px')

    We can implement this with reactive variables so long as the entire array is replaced whenever it is mutated.




Platform = {
  isIOS: function () {
    return (!!navigator.userAgent.match(/iPad/i) || !!navigator.userAgent.match(/iPhone/i) || !!navigator.userAgent.match(/iPod/i))
           || Session.get('platformOverride') === 'iOS';
  },

  isAndroid: function () {
    return navigator.userAgent.indexOf('Android') > 0
           || Session.get('platformOverride') === 'Android';
  }
};

Template.registerHelper('isIOS', function () {
  return Platform.isIOS();
});

Template.registerHelper('isAndroid', function () {
  return Platform.isAndroid();
});

Template.ionBody.helpers({
  platformClasses: function () {
    var classes = ['grade-a'];

    if (Meteor.isCordova) {
      classes.push('platform-cordova');
    }
    if (Meteor.isClient) {
      classes.push('platform-web');
    }
    if ((Meteor.isCordova && Platform.isIOS()) || Session.get('platformOverride') === 'iOS') {
      classes.push('platform-ios');
    }
    if ((Meteor.isCordova && Platform.isAndroid()) || Session.get('platformOverride') === 'Android') {
      classes.push('platform-android');
    }

    return classes.join(' ');
  }
});





























css
  '.page':
    'height': '10px'
    '.title':
      'fontSize': '2em'
    '.nav': css().fullWidth().height(90).backgroundColor('blue').value()
  '.overlay': _.extend css.fullWidth(), css.color('blue') # css().fullWidth().color('blue').value()
    'fontSize': 10

# => creates 2 css rules:
# .page {
#   height: 10px;
# }
# .page .title {
#   font-size: 2em;
# }

css.height(10)
# => {height: 10}

page = css('.page')
# new object selector

page.height(10).width(10)
# writes a 2 css rules
# .page {
#   height: 10px;
#   width: 10px;
# }


# chainable
css().height(10).width(50).value()
# => {height:10, width:50}



# Holy grail. create both height functions with this mixin function
css.mixin 'height', (value) -> {height: value}








