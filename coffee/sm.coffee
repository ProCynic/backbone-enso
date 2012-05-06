typematch = (obj, str) ->
  primitives = ['string', 'function', 'object', 'number', 'boolean']
  return typeof obj is str if str in primitives
  return _.isArray(obj) if str is 'array'
  try
    return obj instanceof (eval str)
  catch err
    return false

Model_Enso = Backbone.Model.extend
  validate: (attrs) ->
    schema = @constructor.schema
    primitives = ['string', 'function', 'object', 'number', 'boolean']
    for k in _.keys(schema)
      if not attrs[k]?
        return 'required: ' + k if not schema[k].optional
      else
        # typecheck
        return 'type mismatch: ' + k if not typematch attrs[k], schema[k].type

        # propigate validation
        if attrs[k] instanceof Backbone.Model
          v = attrs[k].validate(attrs[k].attributes)
          return v if v?

        # inverse
        if schema[k].inverse?
          return 'primitives can\'t have inverses' + k if not (schema[k].type instanceof Backbone.Model or schema[k].type instanceof Backbone.Collection)
          othertype = eval schema[k].type #This is the type of the object that containse the inverse field
          othertype = othertype.model if othertype instanceof Backbone.Collection #make it the actual model type if it's a collection
          #other is now the Model object that contains the inverse attribute
          inverse = othertype.constructor.schema[schema[k].inverse] #inverse is the field in the othertype SCHEMA
          return 'bad inverse: ' + k if not inverse? or inverse.inverse isnt k #inverse must be reciprocal
          this_side = attrs[k] # the field in the actual instance on this side
          other_side = this_side.get schema[k].inverse # the field in the other object
          x = this_side instanceof Backbone.Model
          y = (eval inverse.type) instanceof Backbone.Model

          if x and y # OneToOne
            return 'not inverse' + k if other_side isnt this
          #if not x and y # ManyToOne #check on other side

          if x and not y #OneToMany
            return 'not inverse' + k if not other_side.get(this.id)?
          if not x and not y # ManyToMany
            this_side.each (o) -> return 'not inverse' + k if o.get(schema[k].inverse) isnt this


# ------
# Models
# ------


Author = Model_Enso.extend {},
  schema:
    name:
      type: 'string'

Book = Model_Enso.extend
  validate: (attrs) ->
    s = Model_Enso.prototype.validate.call(this, attrs)
    return s if s?
    # non-schema related validation.  Don't even bother to override validate if you don't have any
,
  schema:
    author:
      type: 'Author'
      optional: true

Machine = Model_Enso.extend
  initialize: () ->
    @current = @start
,
  schema:
    start:
      type: 'State'
    current:
      type: 'State'
    states:
      type: 'States'
      inverse: 'machine'

State = Model_Enso.extend {},
  schema:
    machine:
      type: 'Machine'
      inverse: 'states'
    name:
      type: 'string'
    out:
      type: 'Transitions'
    in:
      type: 'Transitions'

Transition = Model_Enso.extend {},
  schema:
    from:
      type: 'State'
      inverse: 'out'
    to:
      type: 'State'
      inverse: 'in'
    action:
      type: 'function'
      optional: true

# -----------
# Collections
# -----------

States = Backbone.Collection.extend
  model:State

Transitions = Backbone.Collection.extend
  model:Transition

# -----
# Views
# -----

appView = Backbone.View.extend
  tagname: 'div'
  id: 'main'
  render: () ->
    bob = new Author {name: 'bob'}
    x = new Machine()
    b = new Book {author: bob}
    context =
      heading: new String b.isValid()
    html = Handlebars.templates.main context
    @$el.html html
    return this

# ---
# App
# ---

app = new appView
  el: $('#main')

app.render()