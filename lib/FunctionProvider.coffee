shell = require 'shell'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global functions.
##
class FunctionProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition, 2)

        return true if 'function-call' in classList and 'object' not in classList and 'static' not in classList

        classList = @getClassListForBufferPosition(editor, bufferPosition, 1)

        return true if 'function' in classList
        return true if 'function-call' in classList and 'object' not in classList and 'static' not in classList

        return false

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition, 2)

        if 'function-call' not in classList
            classList = @getClassListForBufferPosition(editor, bufferPosition, 1)

        range = editor.bufferRangeForScopeAtPosition(classList.join('.'), bufferPosition)

        return range

    ###*
     * @param {String} text
     *
     * @return {Promise}
    ###
    getInfoFor: (text) ->
        successHandler = (functions) =>
            if text?[0] != '\\'
                text = '\\' + text

            return null unless functions and text of functions

            return functions[text]

        failureHandler = () ->
            # Do nothing.

        return @service.getGlobalFunctions().then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    handleSpecificNavigation: (editor, range, text) ->
        successHandler = (info) =>
            return if not info?

            if info.filename?
                atom.workspace.open(info.filename, {
                    initialLine    : (info.startLine - 1),
                    searchAllPanes : true
                })

            else
                shell.openExternal(@service.getDocumentationUrlForFunction(info.name))

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(text).then(successHandler, failureHandler)
