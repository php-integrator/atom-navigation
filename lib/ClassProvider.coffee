$ = require 'jquery'
fuzzaldrin = require 'fuzzaldrin'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for classes (i.e. being able to click class, interface and trait names to navigate to them).
##
class ClassProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.entity.inherited-class, .support.namespace, .support.class, .comment-clickable .region'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.entity.inherited-class, .support.namespace, .support.class, .comment-clickable .region'

    ###*
     * A list of all markers that have been placed inside comments to allow code navigation there as well.
    ###
    markers: null

    ###*
     * @inheritdoc
    ###
    activate: (@service) ->
        super(@service)

        @markers = {}

        atom.workspace.observeTextEditors (editor) =>
            editor.onDidSave (event) =>
                @rescanMarkers(editor)

            @registerMarkers editor

    ###*
     * @inheritdoc
    ###
    deactivate: () ->
        super()

        @removeMarkers()

    registerEvents: (editor) ->
        super(editor)

        if editor.getGrammar().scopeName.match /text.html.php$/
            # This is needed to be able to alt-click class names inside comments (docblocks).
            editor.onDidChangeCursorPosition (event) =>
                return if not event.altKey

                longTitle = editor.getLongTitle()

                return if longTitle not of @markers

                markerProperties =
                    containsBufferPosition: event.newBufferPosition

                markers = event.cursor.editor.findMarkers markerProperties

                for key,marker of markers
                    for allMarker in @markers[longTitle]
                        if marker.id == allMarker.id
                            @gotoFromWord(event.cursor.editor, marker.getProperties().term)
                            break

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        if term == undefined || term.indexOf('$') == 0
            return

        term = @service.determineFullClassName(editor, term)

        classes = @service.getClassList()

        return unless classes

        # See what matches we have for this class name.
        flatList = (obj for name,obj of classes)

        matches = fuzzaldrin.filter(flatList, term, key: 'name')

        if not matches or matches[0]?.name != term
            return

        atom.workspace.open(matches[0].filename, {
            initialLine    : (matches[0].startLine - 1),
            searchAllPanes : true
        })

    ###*
     * @inheritdoc
    ###
    getSelectorFromEvent: (event) ->
        return @service.getClassSelectorFromEvent(event)

    ###*
     * Register any markers that you need.
     *
     * @param {TextEditor} editor The editor to search through.
    ###
    registerMarkers: (editor) ->
        text = editor.getText()
        rows = text.split('\n')

        for key,row of rows
            regex = /@param|@var|@return|@throws|@see/g

            if regex.test(row)
                @addMarkerToCommentLine(row.split(' '), parseInt(key), editor, true)

    ###*
     * Removes any annotations that were created for the specified editor.
     *
     * @param {TextEditor} editor
    ###
    removeMarkersFor: (editor) ->
        @removeMarkersByKey(editor.getLongTitle())

    ###*
     * Removes any annotations that were created with the specified key.
     *
     * @param {string} key
    ###
    removeMarkersByKey: (key) ->
        for i,marker of @markers[key]
            marker.destroy()

        @markers[key] = []

    ###*
     * Removes any annotations (across all editors).
    ###
    removeMarkers: () ->
        for key,markers of @markers
            @removeMarkersByKey(key)

        @markers = {}

    ###*
     * Rescans the editor, updating all annotations.
     *
     * @param {TextEditor} editor The editor to search through.
    ###
    rescanMarkers: (editor) ->
        @removeMarkersFor(editor)
        @registerMarkers(editor)

    ###*
     * Analyses the words array given for any classes and then creates a marker for them.
     *
     * @param {array} words           The array of words to check.
     * @param {int} rowIndex          The current row the words are on within the editor.
     * @param {TextEditor} editor     The editor the words are from.
     * @param {bool} shouldBreak      Flag to say whether the search should break after finding 1 class.
     * @param {int} currentIndex  = 0 The current column index the search is on.
     * @param {int} offset        = 0 Any offset that should be applied when creating the marker.
    ###
    addMarkerToCommentLine: (words, rowIndex, editor, shouldBreak, currentIndex = 0, offset = 0) ->
        for key,value of words
            regex = /^\\?([A-Za-z0-9_]+)\\?([A-Za-zA-Z_\\]*)?/g
            keywordRegex = /^(array|object|bool|string|static|null|boolean|void|int|integer|mixed|callable)$/gi

            if regex.test(value) && keywordRegex.test(value) == false
                if value.includes('|')
                    @addMarkerToCommentLine value.split('|'), rowIndex, editor, false, currentIndex, parseInt(key)

                else
                    range = [
                        [rowIndex, currentIndex + parseInt(key) + offset],
                        [rowIndex, currentIndex + parseInt(key) + value.length + offset]
                    ]

                    marker = editor.markBufferRange(range)

                    markerProperties =
                        term: value

                    marker.setProperties markerProperties

                    options =
                        type: 'highlight'
                        class: 'comment-clickable comment'

                    editor.decorateMarker marker, options

                    longTitle = editor.getLongTitle()

                    if longTitle not of @markers
                        @markers[longTitle] = []

                    @markers[longTitle].push(marker)

                if shouldBreak == true
                    break

            currentIndex += value.length;
