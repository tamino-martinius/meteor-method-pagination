Package.describe({
    summary: 'Paging with Meteor.methods as source'
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'underscore'],['client','server']);
  api.use(['handlebars', 'templating', 'stylus'],['client']);
  api.add_files(['client.html','client.coffee', 'client.styl'],['client']);
  api.add_files(['extend.js', 'server.coffee'],['server']);
});
