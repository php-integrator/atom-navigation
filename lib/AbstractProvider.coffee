{TextEditor} = require 'atom'

$ = require 'jquery'
SubAtom = require 'sub-atom'

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
     * The service (that can be used to query the source code and contains utility methods).
    ###
    service: null

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
        @subAtom = new SubAtom

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

            @subAtom.add scrollViewElement, 'mousemove', @hoverEventSelectors, (event) =>
                return unless event.altKey

                selector = @getHoverSelectorFromEvent(event)

                return unless selector

                $(selector).addClass('php-integrator-navigation-navigation-possible')

            @subAtom.add scrollViewElement, 'mouseout', @hoverEventSelectors, (event) =>
                selector = @getHoverSelectorFromEvent(event)

                return unless selector

                $(selector).removeClass('php-integrator-navigation-navigation-possible')

            @subAtom.add scrollViewElement, 'click', @clickEventSelectors, (event) =>
                return unless event.altKey

                selector = @getClickSelectorFromEvent(event)

                return unless selector

                return unless not event.handled

                @gotoFromWord(editor, $(selector).text())
                event.handled = true

    ###*
     * Goto from the term given.
     *
     * @param  {TextEditor} editor TextEditor to search for namespace of term.
     * @param  {string}     term   Term to search for.
    ###
    gotoFromWord: (editor, term) ->
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
