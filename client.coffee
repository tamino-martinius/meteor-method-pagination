collMethodPagination = new Meteor.Collection "methodPagination"

Meteor.subscribe "methodPagination"

collMethodPagination.allow
  insert: (userId, item) -> false
  update: (userId, item, fields, modifier) -> false
  remove: (userId, item) -> false

Template["paging_pagination"].events
  "click a[data-page]": (e) ->
    e.preventDefault()
    pageNumber = e.target.dataset.page * 1
    if @pageNumber isnt pageNumber and pageNumber >= 0 and pageNumber <= @maxPageNumber
      @pageNumber = pageNumber
      @update()
    false

Template["paging_pagination"].helpers
  "disabledClass": (trigger) ->
    if trigger
      ""
    else
      "disabled"
  "activeClass": (trigger) ->
    if trigger
      "active"
    else
      ""

Template["paging_sort"].events
  "click .asc": (e) ->
    e.preventDefault()
    if not @sort[@sortExp] is 1
      @sort = {}
      @sort[@sortExp] = 1
      @update()
    false
  "click .desc": (e) ->
    e.preventDefault()
    if not @sort[@sortExp] is -1
      @sort = {}
      @sort[@sortExp] = -1
      @update()
    false

Template["paging_sort"].helpers
  "sortAscClass": ->
    if @sortAsc
      "active"
    else
      ""
  "sortDescClass": ->
    if @sortDesc
      "active"
    else
      ""

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
      sort:
        "_id": 1
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
  sortFor: (title, sortExp) ->
    @title = title
    @sortExp = sortExp
    @sortAsc = false
    @sortDesc = false
    for key, value of @sort
      if key is @sortExp
        @sortAsc = true if value is 1
        @sortDesc = true if value is -1
    @
  update: () ->
    pg = @
    Meteor.call @method, @params, @, (err, res) ->
      if err?
        console.log err
      else
        pg.items = res.items
        pg.totalRecords = res.totalRecords
        pg.filteredRecords = res.filteredRecords
        pg.setPages()
        Session.set pg.id, ++pg.pass

Template["paging"].helpers
  "reloadTrigger": ->
    Session.get @context.id
