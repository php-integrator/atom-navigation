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
     * @var {Object}
    ###
    scopeDescriptorHelper: null

    ###*
     * @param {Object} scopeDescriptorHelper
    ###
    constructor: (@scopeDescriptorHelper) ->

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
