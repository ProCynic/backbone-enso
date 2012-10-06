Record = Backbone.Model.extend
  idAttribute: '_id'
Records = Backbone.Collection.extend
  parse: (response, xhr) -> # Horribly inefficient.  To be removed after rest-now issue #12 is resolved.
    results = []
    _.each response, (e, i, arr) ->
      $.ajax
        url: e.href
        dataType: 'json'
        async: false
        success: (data, textStatus, jqXHR) ->
          results.push data
    return results

Field = Backbone.Model.extend
  validate: (attrs) ->
    return "Field name must contain only A-Z, a-z, or 0-9" if invalid.test attrs.name
    return "Field must have display name" if not attrs.disp? or not typeof(attrs.disp) is 'string'
    return "Field must have type" if not attrs.type?
    return "Field type must be one of 'string', 'number', 'boolean', and 'object'" if not attrs.type in ['string', 'number', 'boolean', 'object']
    return "Field must have a 'required' boolean" if not attrs.required? || typeof attrs.required != 'boolean'

Fields = Backbone.Collection.extend
  model: Field

ObjDefinition = Backbone.Model.extend
  urlRoot: '/objDefinitions'
  idAttribute: '_id'

  validate: (attrs) ->
    invalid = /[^\d\w]/i
    return "Must supply internal name" if not attrs.modelName?
    return "Must supply internal plural name" if not attrs.collName?
    return "Internal name must contain only A-Z, a-z, or 0-9" if invalid.test  attrs.modelName
    return "Internal plural name must contain only A-Z, a-z, or 0-9" if invalid.test  attrs.collName
    return "Must supply display name" if not attrs.dispName?
    return "Must supply plural display name" if not attrs.pluralName?
    return "fields must be an instance of the Fields collection" if attrs.fields? and attrs.fields not instanceof Fields

  instantiate: (scope) ->
    scope.models ?= {}
    scope.collections ?= {}
    model = scope.models[@get 'modelName'] = Record.extend
      validate: (attrs) ->
        @constructor.fields.forEach (field) ->
          name = field.get name
          return "#{name} is required" if field.get required and not attrs[name]?
          return "#{name} must be of type #{field.get type}" if field.get type != 'object' and attrs[name]? and typeof attrs[name] != field.get type
          return "#{name} must be an instance of Record" if field.get type is 'object' and attrs[name]? and (typeof attrs[name] != 'object' or attrs[name] not instanceof Record)
    ,
      fields: @get 'fields'
      name: @get 'dispName'
      plural: @get 'pluralName'
    collection = scope.collections[@get 'collName'] = Records.extend
      model: model
      url: "/#{@get 'collName'}"

ObjDefinitions = Backbone.Collection.extend
  model: ObjDefinition
  url: '/objDefinitions'
  parse: (response, xhr) -> # Horribly inefficient.  To be removed after rest-now issue #12 is resolved.
    results = []
    _.each response, (e, i, arr) ->
      $.ajax
        url: e.href
        dataType: 'json'
        async: false
        success: (data, textStatus, jqXHR) ->
          results.push data
    return results
###
objDefs = new ObjDefinitions()
objDefs.fetch
  success: (collection, response) ->
    collection.forEach (e, i, arr) ->
      e.instantiate this
###