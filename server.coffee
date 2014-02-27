collMethodPagination = new Meteor.Collection "methodPagination"

Meteor.publish "methodPagination", () ->
  collMethodPagination.find
    userId: @userId

observers = {}
observerDuration = 30*60*1000 # 30 minutes

@getPaging = (collection, query, pageSettings, options = {}) ->
  for pagingId, observer of observers
    if +new Date() - observer.createdAt > observerDuration
      observer.stop()
      delete observers[pagingId]
  userId = Meteor.userId()
  options.skip = pageSettings.pageNumber * pageSettings.pageSize
  options.limit = pageSettings.pageSize
  items = collection.find(query, options).fetch()
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

  totalRecords: collection.find(query).count()
  items: items

@emptyPaging =
  totalRecords: 0
  items: []
