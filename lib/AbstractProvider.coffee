$ = require 'jquery'
SubAtom = require 'sub-atom'

module.exports =

##*
# Base class for providers.
##
class AbstractProvider
    ###*
     * The class selectors for which a hover or click event can be triggered.
    ###
    eventSelectors: ''

    ###*
     * The service (that can be used to query the source code and contains utility methods).
    ###
    service: null

    ###*
     * Contains global package settings.
    ###
    config: null

    ###*
     * The subatom that is used to register events for each editor.
    ###
    subAtom: null

    ###*
     * A list of disposables to dispose when the package deactivates.
    ###
    disposables: null

    ###*
     * Constructor.
     *
     * @param {Config} config
    ###
    constructor: (@config) ->

    ###*
     * Initializes this provider.
     *
     * @param {mixed} service
    ###
    activate: (@service) ->
        dependentPackage = 'language-php'

        # It could be that the dependent package is already active, in that case we can continue immediately. If not,
        # we'll need to wait for the listener to be invoked
        if atom.packages.isPackageActive(dependentPackage)
            @doActualInitialization()

        atom.packages.onDidActivatePackage (packageData) =>
            return if packageData.name != dependentPackage

            @doActualInitialization()

        atom.packages.onDidDeactivatePackage (packageData) =>
            return if packageData.name != dependentPackage

            @deactivate()

    ###*
     * Does the actual initialization.
    ###
    doActualInitialization: () ->
        {CompositeDisposable} = require 'atom';

        @subAtom     = new SubAtom()
        @disposables = new CompositeDisposable()

        @disposables.add atom.workspace.observeTextEditors (editor) =>
            @registerEvents editor

        # When you go back to only have one pane the events are lost, so need to re-register.
        @disposables.add atom.workspace.onDidDestroyPane (pane) =>
            panes = atom.workspace.getPanes()

            if panes.length == 1
                @registerEventsForPane(panes[0])

        # Having to re-register events as when a new pane is created the old panes lose the events.
        @disposables.add atom.workspace.onDidAddPane (observedPane) =>
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
            if atom.workspace.isTextEditor(paneItem)
                @registerEvents(paneItem)

    ###*
     * Deactives the provider.
    ###
    deactivate: () ->
        if @disposables
            @disposables.dispose()
            @disposables = null

        if @subAtom
            @subAtom.dispose()
            @subAtom = null

    ###*
     * Registers the mouse events for alt-click.
     *
     * @param {TextEditor} editor TextEditor to register events to.
    ###
    registerEvents: (editor) ->
        if /text.html.php$/.test(editor.getGrammar().scopeName)
            textEditorElement = atom.views.getView(editor)
            scrollViewElement = $(textEditorElement.shadowRoot).find('.scroll-view')

            @subAtom.add scrollViewElement, 'mousemove', @eventSelectors, (event) =>
                @onMouseMove(editor, event)

            @subAtom.add scrollViewElement, 'mouseout', @eventSelectors, (event) =>
                @onMouseOut(editor, event)

            @subAtom.add scrollViewElement, 'click', @eventSelectors, (event) =>
                @onMouseClick(editor, event)

    ###*
     * Indicates if the specified selector in the editor is valid for navigation.
     *
     * @param {TextEditor}  editor
     * @param {HTMLElement} selector
     *
     * @return {boolean}
    ###
    isValidForNavigation: (editor, selector) ->
        return true

    ###*
     * Handles a mouse move event.
     *
     * @param {TextEditor}   editor
     * @param {jQuery.event} event
    ###
    onMouseMove: (editor, event) ->
        return unless @areEventMouseModifiersValid(event)

        selector = @getHoverSelectorFromEvent(event)

        return unless selector
        return unless @isValidForNavigation(editor, selector)

        bufferPosition = atom.views.getView(editor).component.screenPositionForMouseEvent(event)

        text = @getClickedTextByEvent(editor, event)

        successHandler = (isValid) =>
            if isValid
                $(selector).addClass('php-integrator-navigation-navigation-possible')

            else
                $(selector).addClass('php-integrator-navigation-navigation-impossible')

        failureHandler = () =>
            $(selector).addClass('php-integrator-navigation-navigation-impossible')

        @activePromise = @isValid(editor, bufferPosition, text).then(successHandler, failureHandler)

    ###*
     * Handles a mouse out event.
     *
     * @param {TextEditor}   editor
     * @param {jQuery.event} event
    ###
    onMouseOut: (editor, event) ->
        selector = @getHoverSelectorFromEvent(event)

        return unless selector
        return unless @isValidForNavigation(editor, selector)

        cleanupHandler = () ->
            $(selector).removeClass('php-integrator-navigation-navigation-possible')
            $(selector).removeClass('php-integrator-navigation-navigation-impossible')

        if @activePromise
            @activePromise.then(cleanupHandler)

        else
            cleanupHandler()

    ###*
     * Handles a mouse click event.
     *
     * @param {TextEditor}   editor
     * @param {jQuery.event} event
    ###
    onMouseClick: (editor, event) ->
        return unless @areEventMouseModifiersValid(event)

        selector = @getClickSelectorFromEvent(event)

        return unless selector
        return unless not event.handled
        return unless @isValidForNavigation(editor, selector)

        bufferPosition = atom.views.getView(editor).component.screenPositionForMouseEvent(event)

        text = @getClickedTextByEvent(editor, event)

        @gotoFromWord(editor, bufferPosition, text)

        event.handled = true

    ###*
     * Retrieves the clicked text for an event.
     *
     * @param {TextEditor}   editor
     * @param {jQuery.event} event
     *
     * @return {string|null}
    ###
    getClickedTextByEvent: (editor, event) ->
        selector = @getClickSelectorFromEvent(event)

        return null unless selector

        return $(selector).text()

    ###*
     * Indicates if the specified event has the correct mouse modifier kesy held down.
     *
     * @param  {TextEditor} editor TextEditor to search for namespace of term.
     * @param {Point}       bufferPosition
     * @param  {string}     term   Term to search for.
     *
     * @return {boolean}
    ###
    areEventMouseModifiersValid: (event) ->
        return false if @config.get('navigationRequireAltKey') and not event.altKey
        return false if @config.get('navigationRequireMetaKey') and not event.metaKey
        return false if @config.get('navigationRequireCtrlKey') and not event.ctrlKey
        return false if @config.get('navigationRequireShiftKey') and not event.shiftKey

        return true

    ###*
     * Indicates if the specified term is valid for navigating to.
     *
     * @param {TextEditor} editor         TextEditor to search for namespace of term.
     * @param {Point}      bufferPosition
     * @param {string}     term           Term to search for.
     *
     * @return {Promise}
    ###
    isValid: (editor, bufferPosition, term) ->
        throw new Error("This method is abstract and must be implemented!")

    ###*
     * Goto from the term given.
     *
     * @param {TextEditor} editor         TextEditor to search for namespace of term.
     * @param {Point}      bufferPosition
     * @param {string}     term           Term to search for.
    ###
    gotoFromWord: (editor, bufferPosition, term) ->
        throw new Error("This method is abstract and must be implemented!")

    ###*
     * Gets the correct selector when a selector is hovered over.
     *
     * @param {jQuery.Event} event A jQuery event.
     *
     * @return {Object|null} A selector to be used with jQuery.
    ###
    getHoverSelectorFromEvent: (event) ->
        return event.currentTarget

    ###*
     * Gets the correct selector when a selector is clicked.
     *
     * @param {jQuery.Event} event A jQuery event.
     *
     * @return {Object|null} A selector to be used with jQuery.
    ###
    getClickSelectorFromEvent: (event) ->
        return event.currentTarget
