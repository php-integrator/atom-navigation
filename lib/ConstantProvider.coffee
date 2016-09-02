AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global constants.
##
class ConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    eventSelectors: '.constant.other.php, .support.other.namespace.php'

    ###*
     * @inheritdoc
    ###
    isValidForNavigation: (editor, selector) ->
        # The selector from this provider will still match class constants due to the way SubAtom does its class
        # selector checks. Filter these out.
        return if selector[0].className.indexOf('other class php') != -1 then false else true

    ###*
     * Convenience method that returns information for the specified term.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {string}     term
     *
     * @return {Promise}
    ###
    getInfoFor: (editor, bufferPosition, term) ->
        successHandler = (constants) =>
            if term?[0] != '\\'
                term = '\\' + term

            return null unless constants and term of constants
            return null unless constants[term].filename

            return constants[term]

        failureHandler = () ->
            # Do nothing.

        return @service.getGlobalConstants().then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    isValid: (editor, bufferPosition, term) ->
        successHandler = (info) =>
            return if info then true else false

        failureHandler = () ->
            return false

        @getInfoFor(editor, bufferPosition, term).then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, bufferPosition, term) ->
        successHandler = (info) =>
            return if not info?

            atom.workspace.open(info.filename, {
                initialLine    : (info.startLine - 1),
                searchAllPanes : true
            })

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(editor, bufferPosition, term).then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    getHoverSelectorFromEvent: (event) ->
        return @getClassSelectorFromEvent(event)

    ###*
     * @inheritdoc
    ###
    getClickSelectorFromEvent: (event) ->
        return @getClassSelectorFromEvent(event)

    ###*
     * Gets the correct selector for the constant that is part of the specified event.
     *
     * @param {jQuery.Event} event A jQuery event.
     *
     * @return {object|null} A selector to be used with jQuery.
    ###
    getClassSelectorFromEvent: (event) ->
        selector = event.currentTarget

        $ = require 'jquery'

        if $(selector).prev().hasClass('namespace') && $(selector).hasClass('constant')
            return $([$(selector).prev()[0], selector])

        if $(selector).next().hasClass('constant') && $(selector).hasClass('namespace')
            return $([selector, $(selector).next()[0]])

        return $(selector)
