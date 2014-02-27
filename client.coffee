collMethodPagination = new Meteor.Collection "methodPagination"

Meteor.subscribe "methodPagination"

collMethodPagination.allow
  insert: (userId, item) -> false
  update: (userId, item, fields, modifier) -> false
  remove: (userId, item) -> false

Template["paging-pagination"].events
  "click a[data-page]": (e) ->
    e.preventDefault()
    pageNumber = e.target.dataset.page * 1
    if @pageNumber isnt pageNumber and pageNumber >= 0 and pageNumber <= @maxPageNumber
      @pageNumber = pageNumber
      @update()
    false

observer = null

class @Paging
  constructor: (options) ->
    pg = @
    defaults =
      id: "paging-#{(new Meteor.Collection.ObjectID)._str}"
      items: []
      pageSize: 20
      pageNumber: 0
      autoUpdate: true
      totalRecords: 0
      params: {}
      pageNumber: 0
      method: "PLEASE ADD METHOD PARAM!"
      pass: 0
    _.extend @, defaults, options
    for key, template of @templates
      @templates[key] = Template[template] if _.isString template
    @update()
    Session.set pg.id, @pass
    observer.stop() if observer?
    observer = collMethodPagination.find({pagingId: @id}).observe
      "added": (changes) ->
        if pg.autoUpdate
          pg.update()
        if changes.itemId?
          if changes.fields?
            pg.itemChanged(changes.itemId, changes.fields) if pg.itemChanged?
          else
            pg.itemDeleted(changes.itemId) if pg.itemDeleted?
        else
          pg.itemAdded() if pg.itemAdded?
    return
  setPages: () ->
    @maxPageNumber = Math.ceil(@totalRecords / @pageSize) - 1
    @nextPage = @pageNumber + 1
    @prevPage = @pageNumber - 1
    @firstPage = @pageNumber > 0
    @lastPage = @pageNumber < @maxPageNumber
    @pages = []
    for number in [0..@maxPageNumber]
      @pages.push number
    return
  proxy: (number) ->
    @number = number + 1
    @page = number
    @active = @pageNumber is number
    @
  update: () ->
    pg = @
    Meteor.call @method, @params, @, (err, res) ->
      if err?
        console.log err
      else
        pg.items = res.items
        pg.totalRecords = res.totalRecords
        pg.setPages()
        Session.set pg.id, ++pg.pass
  render: (tmpl) ->
    Session.get @id
    tmpl @
