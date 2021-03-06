Foxie = require 'foxie'

module.exports = class ControlsView
  constructor: (@editor) ->
    @rootView = @editor
    @model = @editor.model.timeControl

    do @_prepareNodes
    do @_prepareKeyboard

    @model.on 'play-state-change', => do @_updatePlayState
    @_curY = 0

    @mainBoxModel = @editor.model.mainBox
    @mainBox = @editor.mainBox

    do @_updatePosition

    @editor.model.mainBox.on 'height-change', => do @_updatePosition
    @editor.model.mainBox.on 'visibility-toggle', => do @_updatePosition

    do @_updatePlayState

    @audioModel = @editor.model.audio
    @audioModel.on 'ready-state-change', => do @_updateReadyState

    do @_updateReadyState

  _updateReadyState: ->
    if @audioModel.isReady()
      @playPauseNode.addClass 'ready'
    else
      @playPauseNode.removeClass 'ready'

  _prepareNodes: ->
    @node = Foxie('.theatrejs-controls').trans(500)
    @node.putIn @editor.node

    do @_prepareFullscreenNode
    do @_prepareJumpToPrevMarkerNode
    do @_preparePlayPauseNode
    do @_prepareJumpToNextMarkerNode

  _preparePlayPauseNode: ->
    @playPauseNode = Foxie '.theatrejs-controls-playPause'
    @playPauseNode.putIn @node

    @rootView.moosh.onClick(@playPauseNode)
    .onDone =>
      do @_togglePlayState

  _prepareFullscreenNode: ->
    @toggleFullscreenNode = Foxie '.theatrejs-controls-fullscreen'
    @toggleFullscreenNode.putIn @node

  _prepareJumpToPrevMarkerNode: ->
    @jumpToPrevMarkerNode = Foxie '.theatrejs-controls-jumpToPrevMarker'
    @jumpToPrevMarkerNode.putIn @node

    @rootView.moosh.onClick(@jumpToPrevMarkerNode)
    .onDone =>
      do @model.jumpToPrevMarker

  _prepareJumpToNextMarkerNode: ->
    @jumpToNextMarkerNode = Foxie '.theatrejs-controls-jumpToNextMarker'
    @jumpToNextMarkerNode.putIn @node

    @rootView.moosh.onClick(@jumpToNextMarkerNode)
    .onDone =>
      do @model.jumpToNextMarker

  _prepareKeyboard: ->
    @rootView.kilid.on 'space', =>
      do @_togglePlayState

    @rootView.kilid.on 'home', =>
      do @model.jumpToFocusBeginning

    @rootView.kilid.on 'ctrl+home', =>
      do @model.jumpToBeginning

    @rootView.kilid.on 'end', =>
      do @model.jumpToFocusEnd

    @rootView.kilid.on 'ctrl+end', =>
      do @model.jumpToEnd

    @rootView.kilid.on 'right', =>
      @model.seekBy 16

    @rootView.kilid.on 'left', =>
      @model.seekBy -16

    @rootView.kilid.on 'shift+right', =>
      @model.seekBy 48

    @rootView.kilid.on 'shift+left', =>
      @model.seekBy -48

    @rootView.kilid.on 'alt+right', =>
      @model.seekBy 2

    @rootView.kilid.on 'alt+left', =>
      @model.seekBy -2

  _updatePosition: ->
    newY = -@mainBox.getCurrentHeight() - 8
    return if newY is @_curY
    @_curY = newY
    @node.moveYTo(@_curY)
    return

  _togglePlayState: ->
    @model.togglePlayState()

  _updatePlayState: ->
    if @model.isPlaying()
      @playPauseNode.addClass 'playing'
    else
      @playPauseNode.removeClass 'playing'
    return