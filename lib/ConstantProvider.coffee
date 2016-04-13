AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global constants.
##
class ConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    eventSelectors: '.constant.other.php'

    ###*
     * @inheritdoc
    ###
    isValidForNavigation: (editor, selector) ->
        # The selector from this provider will still match class constants due to the way SubAtom does its class
        # selector checks. Filter these out.
        return if selector.className.indexOf('other class php') != -1 then false else true

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
