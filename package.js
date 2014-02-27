Package.describe({
    summary: 'Paging with Meteor.methods as source'
});
 
Package.on_use(function (api) {
  api.use(['coffeescript', 'underscore'],['client','server']);
  api.use(['handlebars', 'templating'],['client']);
  api.add_files(['client.html','client.coffee'],['client']);
  api.add_files('server.coffee',['server']);
});