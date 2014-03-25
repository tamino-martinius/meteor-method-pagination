collMethodPagination = new Meteor.Collection "methodPagination"

Meteor.publish "methodPagination", () ->
  collMethodPagination.find
    userId: @userId

observers = {}
observerDuration = 30*60*1000 # 30 minutes

@getPaging = (collection, pageSettings, query, filter = null, options = {}) ->
  for pagingId, observer of observers
    if +new Date() - observer.createdAt > observerDuration
      observer.stop()
      delete observers[pagingId]
  filterQuery = deepExtend {}, query, filter, 10
  userId = Meteor.userId()
  options.sort = pageSettings.sort if not options.sort?
  options.skip = pageSettings.pageNumber * pageSettings.pageSize
  options.limit = pageSettings.pageSize
  items = collection.find(filterQuery, options).fetch()
  itemIds = _.pluck items, "_id"
  observers[pageSettings.id].stop() if observers[pageSettings.id]?
  collMethodPagination.remove
    userId: userId
    pagingId: pageSettings.id
  observers[pageSettings.id] = collection.find({_id: {$in: itemIds}}).observeChanges
    "added": (itemId, fields) ->
      if collMethodPagination.find({userId: userId, pagingId: pageSettings.id}).count() is 0
        collMethodPagination.insert
          userId: userId
          pagingId: pageSettings.id
    "changed": (itemId, fields) ->
      collMethodPagination.remove
        userId: userId
        pagingId: pageSettings.id
        itemId: itemId
      collMethodPagination.insert
        userId: userId
        pagingId: pageSettings.id
        itemId: itemId
        fields: fields
    "removed": (itemId) ->
      collMethodPagination.remove
        userId: userId
        pagingId: pageSettings.id
        itemId: itemId
      collMethodPagination.insert
        userId: userId
        pagingId: pageSettings.id
        itemId: itemId
  observers[pageSettings.id].createdAt = +new Date()
  totalRecords = collection.find(query).count()
  totalRecords: totalRecords
  filteredRecords: if filterQuery? then collection.find(filterQuery).count() else totalRecords
  items: items

@emptyPaging =
  totalRecords: 0
  items: []
