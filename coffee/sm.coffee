Model_Enso = Backbone.Model.extend
  validate: (attrs) ->
    schema = @constructor.schema
    primitives = ['string', 'function', 'object', 'number', 'boolean']
    for k in _.keys(schema)
      if not attrs[k]?
        return 'required: ' + k if not schema[k].optional
      else
        if schema[k].type in primitives
          return 'type mismatch: ' + k if typeof attrs[k] isnt schema[k].type
        else
          return 'type mismatch: ' + k if not (attrs[k] instanceof (eval schema[k].type)) #TODO something other than eval
          if attrs[k] instanceof Backbone.Model
            v = attrs[k].validate(attrs[k].attributes)
            return v if v?

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

Machine = Backbone.Model.extend
  validate: (attrs) ->
    #start
    return 'must have start state' if not (attrs.start instanceof State)

    #states
    return 'states must be a collection of states' if not (attrs.states instanceof States)
,
  schema:
    start:
      type: 'State'
    states:
      type: 'States'
      inverse: 'machine'

State = Backbone.Model.extend
  validate: (attrs) ->
    # machine
    return 'must belong to a machine' if not (attrs.machine instanceof Machine)

    return 'state must belong to specified machine' if not attrs.machine.states.get(this.id)?

    #name
    return 'name must be a string' if attrs.name? and typeof attrs.name isnt 'string'

    #out
    return 'out must be a collection of transitions' if not (attrs.out instanceof Transitions)

    #in
    return 'in must be a collection of transitions' if not (attrs.in instanceof Transitions)

Transition = Backbone.Model.extend
  validate: (attrs) ->
    #from
    return 'from must be a state' if not (attrs.from instanceof State)

    return 'out is the inverse of from' if not attrs.from.out.get(this.id)?

    #to
    return 'to must be a state' if not (attrs.to instanceof State)

    return 'in is the inverse of to' if not attrs.to.in.get(this.id)?

    #action
    return 'action must be a function' if attrs.action? and typeof attrs.action isnt 'function'

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
    bob = new Author {name: 'bob bobington'}
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