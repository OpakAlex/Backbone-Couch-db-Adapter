Backbone-Couch-db-Adapter
=========================

Create simple backbone adapter for couch db

First step use this:
https://github.com/benvinegar/couchdb-xd

add Couch.init in your js code
###example:
    class CounchInit
     constructor: (@host, @user, pass) ->
    @user = window.gon.current_user unless @user #{login: 'login', name: 'I am'} #if use gon
    Couch.init ->
      server = new Couch.Server('http://localhost:5984') #or you server
      window.db = new Couch.Database(server, 'db_name');
      new BackBoneCouchDbAdapter()
      PlayerApp.appView = new PlayerApp.AppView collection: new PlayerApp.PlayListCollection

###Then, update your backbone collections:
    class ExampleApp.ExampleList extends Backbone.Collection
      view: 'your view'
      model: ExampleApp.Example
      url: '#'

Try it!
