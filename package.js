Package.describe({
  name: 'ccorcos:reactive-css',
  summary: 'Define reactive CSS rules in Javascript or (preferably ;) Coffeescript.',
  version: '1.0.1',
  git: 'https://github.com/ccorcos/meteor-reactive-css'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1');

  api.use([
    'coffeescript',
    'underscore'
  ], 'client');

  api.addFiles([
    'lib/css.coffee',
    'lib/mixins.coffee',
    'lib/helpers.coffee',
  ], 'client');

});