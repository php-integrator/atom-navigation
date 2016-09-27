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
    config: null

    ###*
     * @param {Config} config
    ###
    constructor: (@config) ->

    ###*
     * @param {Object} service
    ###
    setService: (service) ->
        @service = service

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {Array}
    ###
    getClassListForBufferPosition: (editor, bufferPosition) ->
        scopesArray = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopesArray()

        return [] if not scopesArray?

        classes = scopesArray.pop()

        return [] if not classes?

        return classes.split('.')

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
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
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
     * @param {String} name
     *
     * @return {String}
    ###
    getNormalizeFqcnDocumentationUrl: (name) ->
        return name.replace(/\\/g, '-').substr(1).toLowerCase()

    ###*
     * @param {String} name
     *
     * @return {String}
    ###
    getNormalizeMethodDocumentationUrl: (name) ->
        return name.replace(/^__/, '')
