{Point, Range} = require 'atom'

module.exports =

##*
# Base class for providers.
##
class AbstractProvider
    ###*
     * @var {Object}
    ###
    service: null

    ###*
     * @param {Object} service
    ###
    setService: (service) ->
        @service = service

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {boolean}
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        throw new Error("This method is abstract and must be implemented!")

    ###*
     * @param {TextEditor} editor
     * @param {Range}      range
     * @param {String}     text
    ###
    handleNavigation: (editor, range, text) ->
        return if not @service

        @handleSpecificNavigation(editor, range, text)

    ###*
     * @param {TextEditor} editor
     * @param {Range}      range
     * @param {String}     text
    ###
    handleSpecificNavigation: (editor, range, text) ->
        throw new Error("This method is abstract and must be implemented!")

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {Number}     climbCount
     *
     * @return {Array}
    ###
    getClassListForBufferPosition: (editor, bufferPosition, climbCount = 1) ->
        scopesArray = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopesArray()

        return [] if not scopesArray?
        return [] if climbCount > scopesArray.length

        classes = scopesArray[scopesArray.length - climbCount]

        return [] if not classes?

        return classes.split('.')

    ###*
     * Skips the scope descriptor at the specified location, returning the class list of the next one.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {Array}
    ###
    getClassListFollowingBufferPosition: (editor, bufferPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition)

        range = editor.bufferRangeForScopeAtPosition(classList.join('.'), bufferPosition)

        return [] if not range?

        ++range.end.column

        classList = @getClassListForBufferPosition(editor, range.end)

        return classList
