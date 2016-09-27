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
        classList = @getClassListForBufferPosition(editor, bufferPosition)

        if 'function' in classList or ('function-call' in classList and 'object' not in classList and 'static' not in classList)
            return true

        return false


    ###*
     * @inheritdoc
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition)

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
                shell.openExternal(@config.get('php_documentation_base_urls').functions + info.name)

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(text).then(successHandler, failureHandler)
