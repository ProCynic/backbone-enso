Machine = Backbone.Model.extend
  validate: (attrs) ->
    if typeof attrs.start isnt State
      return 'must have start state'
    if not _isArray attrs.states
      return 'states must be an array of states'
    for s in attrs.states when typeof s isnt State
      return 'states must be an array of states'

State = Backbone.Model.extend
  validate: (attrs) ->
    if typeof attrs.machine isnt Machine
      return 'must belong to a machine'
    if _indexOf(attrs.machine.states, this) is -1
      return 'state must belong to specified machine'


appView = Backbone.View.extend
  tagname: 'div'
  id: 'main'
  render: () ->
    context =
      heading: 'test'
    html = Handlebars.templates.main context
    @$el.html html
    return this

app = new appView
  el: $('#main')

app.render()