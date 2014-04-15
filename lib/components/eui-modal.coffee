`import styleSupport from '../mixins/style-support'`
`import animationsDidComplete from '../mixins/animations-did-complete'`
`import modalLayout from '../templates/eui-modal'`

modal = Em.Component.extend styleSupport, animationsDidComplete,
  layout: modalLayout
  tagName: 'eui-modal'
  classNames: ['eui-modal']
  classNameBindings: ['class', 'isClosing:eui-closing']
  attributeBindings: ['tabindex']

  class: null

  # Stores the element that had focus before the modal was opened if the user uses the
  # keyboard to open it

  previousFocus: null


  # We don't really want to modal to be focusable, but we do need it to catch all key
  # presses so we can scope the tab key to only tab the modal contents.

  tabindex: -1


  # If the dialog was created programatically we set this to true which renders the
  # view specified by the user instead of yielding.

  programmatic: false


  # Set to true when we want the closing animations to play.

  isClosing: false


  # Determines if the modal contents should be rendered into the DOM

  renderModal: false


  # Proxy for renderModal. Allows us to animate the modal closing by delaying the setting of
  # renderModal until the animation is done playing

  open: Ember.computed (key, value) ->
    # setter
    if arguments.length is 2

      # If we are showing the modal we can do it immediately since it won't bugger animations
      if value
        @set 'renderModal', value

      # Enure that the modal is currently in the DOM before we hide it via hide method
      else
        @hide() if @get 'renderModal'

      value

    # getter
    else
      value = @get 'renderModal'
      value

  .property 'renderModal'


  # Set focus to modal. didInsertElment is for programmtic creation, and didOpenModel does
  # it if eui-modal is being used as a block level component.

  didInsertElement: ->
    if @get 'programmatic'
      # Store orignal focus so we can restore it when the modal is closed
      @set 'previousFocus', $("*:focus")

      @.$().focus()

  didOpenModal: (->
    @.$().focus() if @get 'renderModal'
  ).observes 'renderModal'


  # Remove the Modal from the DOM

  hide: ->
    # Set isClosing to true so the animation class gets added
    @set 'isClosing', true

    @animationsDidComplete().then =>
      @remove()


  # Restore focus to where it was before the modal was opened and remove the modal from
  # the DOM via the renderModal flag, or if it was created programattically by destroying it.

  remove: ->
    @get('previousFocus')?.focus()

    if @get 'programmatic'
      @destroy()
    else
      @setProperties { isClosing: false, renderModal: false }


  # Actions will not bubble up from the programmatic modal so we need to create
  # pre-defined actions that the user can trigger to close the modal

  actions:
    cancel: (context) ->
      @sendAction 'cancel', context
      @hide()

    accept: (context) ->
      @sendAction 'accept', context
      @hide()


  # Catch and handle key presses

  keyDown: (event) ->
    # TAB
    @constrainTabNavigation(event) if event.keyCode == 9

    # ESC
    if event.keyCode == 27
      @sendAction 'cancel'
      @hide()


  # Makes sure the tab focus cannot leave the modal otherwise keyboard controls will
  # not work and the page may scroll underneath the modal

  constrainTabNavigation: ->
    # TODO
    return

modal.reopenClass
  # Creates the modal programmatically and inserts it into the DOM

  show: (options = {}) ->
    options.renderModal = true
    options.programmatic = true

    modal = this.create options
    modal.container = modal.get('targetObject.container')
    modal.appendTo 'body'
    modal

`export default modal`
