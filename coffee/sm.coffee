appView = Backbone.View.extend
  tagname: 'div'
  id: 'main'
  render: () ->
    source = $('#main-template').html()
    template = Handlebars.compile source
    context =
      heading: 'test'
    html = template context
    this.$el.html html
    return this

app = new appView
  el: $('#main')

app.render()