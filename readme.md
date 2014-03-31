# method-pagination

Paging with `Meteor.methods` as Source

## Client Source

JavaScript

```
var paging;

paging = null;

Template["name"].created = function() {
  return paging = new Paging({
    method: "getRecords",
    pageSize: 5
  });
};

Template["name"].helpers({
  paging: function(options) {
    return paging.render(options.fn);
  }
});
```

CoffeeScript

```
paging = null

Template["name"].created = () ->
  paging = new Paging
    method: "getRecords"
    pageSize: 5

Template["name"].helpers
  ctx: -> paging
```

Spacebars

```
<template name="recordList">
  {{#paging context=ctx}}
    {{#if items}}
      {{#each items}}
        
      {{/each}}
    {{> paging_pagination}}
  {{else}}
    No Data
  {{/paging}}
</template>
```

## Server Source

JavaScript

```
Meteor.methods({
  "getRecords": function(params, pageSettings) {
    if (this.userId != null) {
      return getPaging(records, {}, pageSettings);
    } else {
      throw new Meteor.Error(503, "Nice try");
    }
  }
});
```

CoffeeScript

```
Meteor.methods
  "getRecords": (params, pageSettings) ->
    if @userId?
      return getPaging records, {}, pageSettings
    else
      throw new Meteor.Error 503, "Nice try"
```
