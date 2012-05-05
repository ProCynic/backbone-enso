# ------
# Models
# ------

Machine = Backbone.Model.extend
  validate: (attrs) ->  #Thinking about adding a schema object to Backbone.Model so I don't have to write this every time.
    #start
    return 'must have start state' if typeof attrs.start isnt State

    #states
    return 'states must be a collection of states' if typeof attrs.states isnt States


State = Backbone.Model.extend
  validate: (attrs) ->
    # machine
    return 'must belong to a machine' if typeof attrs.machine isnt Machine

    return 'state must belong to specified machine' if not attrs.machine.states.get(this.id)?

    #name
    return 'name must be a string' if attrs.name? and typeof attrs.name isnt 'string'

    #out
    return 'out must be a collection of transitions' if typeof attrs.out isnt Transitions

    #in
    return 'in must be a collection of transitions' if typeof attrs.in isnt Transitions

Transition = Backbone.Model.extend
  validate: (attrs) ->
    #from
    return 'from must be a state' if typeof attrs.from isnt State

    return 'out is the inverse of from' if not attrs.from.out.get(this.id)?

    #to
    return 'to must be a state' if typeof attrs.to isnt State

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
    x = new
    context =
      heading: 'test'
    html = Handlebars.templates.main context
    @$el.html html
    return this

# ---
# App
# ---

app = new appView
  el: $('#main')

app.render()