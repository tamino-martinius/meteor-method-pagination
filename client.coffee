pagingId = 1


#--- Type checking
isFunction = (object) -> typeof object is "function"
isNumber = (object) -> typeof object is "number"
isString = (object) -> typeof object is "string"
isArray = (object) -> Object::toString.call(object) is "[object Array]"

extend = (target, elements...) ->
  depth = 5
  depth = elements.pop() if elements.length > 0 and isNumber(elements[elements.length - 1])
  target ||= {}
  if depth > 0
    for src in elements
      for srcKey, srcVal of src
        if typeof srcVal is "object" and srcVal? and not srcVal.length?
          target[srcKey] ||= {}
          @extend target[srcKey], srcVal, depth - 1
        else
          target[srcKey] = srcVal
  target

Template["paging-pagination"].events
  "click a[data-page]": (e) ->
    e.preventDefault()
    pageNumber = e.target.dataset.page * 1
    if @pageNumber isnt pageNumber and pageNumber >= 0 and pageNumber <= @maxPageNumber
      @pageNumber = pageNumber
      @update()
    false

class @Paging
  constructor: (options) ->
    pg = @
    defaults =
      id: "paging-#{pagingId++}"
      items: []
      pageSize: 20
      pageNumber: 0
      totalRecords: 0
      params: {}
      pageNumber: 0
      method: "PLEASE ADD METHOD PARAM!"
      pass: 0
    extend @, defaults, options
    for key, template of @templates
      @templates[key] = Template[template] if isString template
    @update()
    console.log @
    Session.set pg.id, @pass
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
