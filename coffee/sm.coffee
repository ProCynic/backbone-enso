appView = Backbone.View.extend
  tagname: 'div'
  id: 'main'
  render: () ->
    context =
      heading: 'test'
    html = Handlebars.templates.main context
    this.$el.html html
    return this

app = new appView
  el: $('#main')

app.render()