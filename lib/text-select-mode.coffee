{CompositeDisposable} = require 'atom'

module.exports = TextSelectMode =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'text-select-mode:toggle': => @toggle()
    @replaceCommands([
      "core:move-up",
      "core:move-down",
      "core:move-left",
      "core:move-right",
      "core:move-to-top",
      "core:move-to-bottom",
      "editor:move-to-beginning-of-line",
      "editor:move-to-end-of-line",
      "editor:move-to-beginning-of-word",
      "editor:move-to-end-of-word",
      "editor:move-to-next-word",
      "editor:move-to-previous-word",
      "editor:move-to-next-word-boundary",
      "editor:move-to-previous-word-boundary",
      "editor:move-to-beginning-of-previous-paragraph",
      "editor:move-to-end-of-previous-paragraph",
      "editor:move-to-beginning-of-next-paragraph",
      "editor:move-to-end-of-next-paragraph",
    ])

    @subscribeCancelCommands([
        "core:cancel",
        "core:copy",
        "core:cut",
        "core:paste"
      ])

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  # Transform a list of "move" commands each into the corresponding "select" command
  # Stop propagation of original command and dispatch the new one
  # Only for text-select-mode text editors
  replaceCommands: (commands) ->
    commands.forEach (command) =>
      newCommand = command.replace("move", "select")

      binding = {}
      binding[command] = (event) ->
        editor = atom.workspace.getActiveEditor()
        atom.commands.dispatch(atom.views.getView(editor), newCommand)
        event.stopImmediatePropagation()

      @subscriptions.add atom.commands.add 'atom-text-editor.text-select-mode', binding

  # Add the effect of cancelling text-select-mode in the active editor for the given commands
  # Do not clear the selection
  subscribeCancelCommands: (commands) ->
    commands.forEach (command) =>
      binding = {}
      binding[command] = (event) =>
        @cancel()

      @subscriptions.add atom.commands.add 'atom-text-editor.text-select-mode', binding

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    view = atom.views.getView(editor)
    view.classList.toggle "text-select-mode"

  cancel: ->
    editor = atom.workspace.getActiveTextEditor()
    view = atom.views.getView(editor)
    view.classList.remove "text-select-mode"
