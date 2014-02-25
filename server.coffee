@getPaging = (collection, query, pageSettings, options = {}) ->
  options.skip = pageSettings.pageNumber * pageSettings.pageSize
  options.limit = pageSettings.pageSize
  totalRecords: collection.find(query).count()
  items: collection.find(query, options).fetch()

@emptyPaging =
  totalRecords: 0
  items: []
