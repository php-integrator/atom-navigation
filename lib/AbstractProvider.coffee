{TextEditor} = require 'atom'

$ = require 'jquery'
SubAtom = require 'sub-atom'

Utility = require './Utility'

module.exports =

##*
# Base class for providers.
##
class AbstractProvider
    ###*
     * The class selectors for which a hover event can be triggered.
    ###
    hoverEventSelectors: ''

    ###*
     * The class selectors for which a click event can be triggered.
    ###
    clickEventSelectors: ''

    ###*
     * The regular expressions that must be matched for go to to kick in.
    ###
    gotoRegex: ''

    ###*
     * The word to jump to after a new editor has been opened. Used mostly to jump to code such as property names, where
     * their location can't be fetched via PHP reflection.
    ###
    jumpWord: ''

    ###*
     * The service (that can be used to query the source code and contains utility methods).
    ###
    service: null

    ###*
     * Initializes this provider.
     *
     * @param {mixed} service
    ###
    activate: (@service) ->
        @subAtom = new SubAtom

        atom.workspace.onDidChangeActivePaneItem (paneItem) =>
            if paneItem instanceof TextEditor && @jumpWord != '' && @jumpWord != undefined
                @jumpTo(paneItem, @jumpWord)
                @jumpWord = ''

        atom.workspace.observeTextEditors (editor) =>
            @registerEvents editor

        # When you go back to only have one pane the events are lost, so need to re-register.
        atom.workspace.onDidDestroyPane (pane) =>
            panes = atom.workspace.getPanes()

            if panes.length == 1
                @registerEventsForPane(panes[0])

        # Having to re-register events as when a new pane is created the old panes lose the events.
        atom.workspace.onDidAddPane (observedPane) =>
            panes = atom.workspace.getPanes()

            for pane in panes
                if pane != observedPane
                    @registerEventsForPane(pane)

    ###*
     * Registers the necessary event handlers for the editors in the specified pane.
     *
     * @param {Pane} pane
    ###
    registerEventsForPane: (pane) ->
        for paneItem in pane.items
            if paneItem instanceof TextEditor
                @registerEvents(paneItem)

    ###*
     * Deactives the provider.
    ###
    deactivate: () ->
        @subAtom.dispose()

    ###*
     * Registers the mouse events for alt-click.
     *
     * @param {TextEditor} editor TextEditor to register events to.
    ###
    registerEvents: (editor) ->
        if editor.getGrammar().scopeName.match /text.html.php$/
            textEditorElement = atom.views.getView(editor)
            scrollViewElement = $(textEditorElement.shadowRoot).find('.scroll-view')

            @subAtom.add scrollViewElement, 'mousemove', @hoverEventSelectors, (event) =>
                return unless event.altKey

                selector = @getSelectorFromEvent(event)

                return unless selector

                $(selector).css('border-bottom', '1px solid ' + $(selector).css('color'))
                $(selector).css('cursor', 'pointer')

                @isHovering = true

            @subAtom.add scrollViewElement, 'mouseout', @hoverEventSelectors, (event) =>
                return unless @isHovering

                selector = @getSelectorFromEvent(event)

                return unless selector

                $(selector).css('border-bottom', '')
                $(selector).css('cursor', '')

                @isHovering = false

            @subAtom.add scrollViewElement, 'click', @clickEventSelectors, (event) =>
                selector = @getSelectorFromEvent(event)

                if selector == null || event.altKey == false
                    return

                if event.handled != true
                    @gotoFromWord(editor, $(selector).text())
                    event.handled = true

    ###*
     * Goto from the current cursor position in the editor.
     *
     * @param {TextEditor} editor TextEditor to pull term from.
    ###
    gotoFromEditor: (editor) ->
        if editor.getGrammar().scopeName.match /text.html.php$/
            position = editor.getCursorBufferPosition()
            term = Utility.getFullWordFromBufferPosition(editor, position)

            termParts = term.split(/(?:\-\>|::)/)
            term = termParts.pop().replace('(', '')

            @gotoFromWord(editor, term)

    ###*
     * Goto from the term given.
     *
     * @param  {TextEditor} editor TextEditor to search for namespace of term.
     * @param  {string}     term   Term to search for.
    ###
    gotoFromWord: (editor, term) ->
        throw new Error("This method is abstract and must be implemented!")

    ###*
     * Gets the correct selector when a selector is clicked.
     *
     * @param {jQuery.Event} event A jQuery event.
     *
     * @return {Object|null} A selector to be used with jQuery.
    ###
    getSelectorFromEvent: (event) ->
        return event.currentTarget

    ###*
     * Returns whether this goto is able to jump using the term.
     *
     * @param {string} term
     *
     * @return {boolean} Whether a jump is possible.
    ###
    canGoto: (term) ->
        return term.match(@gotoRegex)?.length > 0

    ###*
     * Gets the regex used when looking for a word within the editor.
     *
     * @param {string} term Term being search.
     *
     * @return {regex} Regex to be used.
    ###
    getJumpToRegex: (term) ->
        throw new Error("This method is abstract and must be implemented!")

    ###*
     * Jumps to a word within the editor.
     *
     * @param {TextEditor} editor The editor that has the function in.
     * @param {string}     word   The word to find and then jump to.
     *
     * @return {boolean} Whether the finding was successful.
    ###
    jumpTo: (editor, word) ->
        bufferPosition = Utility.findBufferPositionOfWord(editor, word, @getJumpToRegex(word))

        if bufferPosition == null
            return false

        # Small delay to wait for when a editor is being created.
        setTimeout(() ->
            editor.setCursorBufferPosition(bufferPosition, {
                autoscroll: false
            })

            # Separated these as the autoscroll on setCursorBufferPosition didn't work as well.
            editor.scrollToScreenPosition(editor.screenPositionForBufferPosition(bufferPosition), {
                center: true
            })
        , 100)
