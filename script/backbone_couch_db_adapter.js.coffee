###
Create simple adapter for backbone js
run this code after Couch.init function!!!

example:
  class CounchInit
    constructor: (@host, @user, pass) ->
      @user = window.gon.current_user unless @user #{login: 'login', name: 'I am'} #if use gon
      Couch.init ->
        server = new Couch.Server('http://localhost:5984') #or you server
        window.db = new Couch.Database(server, 'db_name');
        new BackBoneCouchDbAdapter()
        PlayerApp.appView = new PlayerApp.AppView collection: new PlayerApp.PlayListCollection

in bacbone collections use option view
example:
class ExampleApp.ExampleList extends Backbone.Collection

# Reference to this collection's model.
  view: 'your view'
  model: ExampleApp.Example
  url: '#'

  done: ->

  remaining: ->
$->
  new CounchInit()

for couch.js use this(step by step):
  https://github.com/benvinegar/couchdb-xd
###

class Backbone.Model extends Backbone.Model
#change the idAttribute since CouchDB uses _id
  idAttribute : "_id"
  clone : ->
    new_model = new @constructor(@)
    #remove _id and _rev attributes on the cloned model object to have a **really** new, unsaved model object.
    #_id and _rev only exist on objects that have been saved, so check for existence is needed.
    delete new_model.attributes._id if new_model.attributes._id
    delete new_model.attributes._rev if new_model.attributes._rev
    new_model

class @CouchQueryAdapter
  constructor: (@db)->
    self = @

  query: (model, opts) ->
    _opts = @make_options(model.constructor.prototype)

  query_model: (model, opts) ->
    _opts = @make_options(model.constructor.prototype)

  get_model: (model, opts)->
    @db.get(model.id, (resp) =>
      opts.success resp
      opts.complete()
    )

  update_model: (model, opts) ->
    @before_save(model)
    vals =  model.toJSON()

    @db.put(model.id, vals, (doc) ->
      opts.success({_id: doc.id, _rev: doc.rev})
      opts.complete()
    )

  create_model: (model, opts)->
    @before_save(model)
    vals = model.toJSON()
    @db.post(vals, (doc) ->
      opts.success({_id: doc.id, _rev: doc.rev})
      opts.complete()
    )

  delete_model: (model, opts) ->
    if model.rev
      @db.destroy(model.id, { rev: model.rev }, (doc) ->
        opts.success()
      )

  #  copy: ->
  #    db.copy('some-record', 'new-record', { rev: 'abcdef123456789' }, (resp) ->
  #      console.log resp
  #    )

  view: (model, opts) ->
    _opts = @make_options(model.constructor.prototype)
    _opts = @user_filter(_opts, model.constructor.prototype.filters)
    url = @get_view_url(model.constructor.prototype.view, model.constructor.prototype.view_url)
    url += "?#{$.param(_opts)}"
    params =
#      data: _opts
      callback: ((res) => (if model.constructor.prototype.read_collback then model.constructor.prototype.read_collback(res, opts) else @view_collback(res, opts)))
    @db.request(url,params)

  view_collback: (res, opts) ->
    _temp = []
    for doc in res.rows
      if doc.value
        _temp.push doc.value
      else
        _temp.push doc.doc
    opts.success _temp
    opts.complete()

  get_view_url: (view, url) ->
    url = "_design/#{@db.name}/_view/#{view}" unless url
    url


  make_options: (opts) ->
    _opts = {}
    for option in @options()
      if opts[option]
        _opts[option] = opts[option]
    _opts

  user_filter: (_opts, opts) ->
    if opts
      for k,v of opts
        _opts[k] = v if v
    _opts

  before_save: (model) ->
    model.before_save() if model.before_save


  options: ->
    [
      "key"
      "keys"
      "startkey"
      "startkey_docid"
      "endkey"
      "endkey_docid"
      "limit"
      "stale"
      "descending"
      "skip"
      "group"
      "group_level"
      "include_docs"
      "inclusive_end"
      "update_seq"
    ]



class @BackBoneCouchDbAdapter
  constructor: (@db) ->
#    @sync()
    @adapter = new CouchQueryAdapter(@db)
    this

  read: (model, opts) ->
    if model.models
      @read_collection model, opts
    else
      @read_model model, opts

  read_model: (model, opts) ->
    @adapter.get_model(model,opts)

  read_collection: (model, opts) ->
    @adapter.view(model, opts)

  create: (model, opts)->
    @adapter.create_model(model,opts)

  update: (model, opts) ->
    @adapter.update_model(model,opts)

  del: (model, opts) ->
    @adapter.delete_model(model,opts)

  sync: ->
    self = @
    Backbone.sync = (method, model, opts) ->
      opts.success ?= ->
      opts.error ?= ->
      opts.complete ?= ->
      if model.constructor.prototype.adapter
        self = model.constructor.prototype.adapter
      switch method
        when "read" then self.read model, opts
        when "create" then self.create model, opts
        when "update" then self.update model, opts
        when "delete" then self.del model, opts
