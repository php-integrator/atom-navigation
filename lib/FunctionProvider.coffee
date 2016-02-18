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
    eventSelectors: '.function-call:not(.object):not(.static), .support.function'

    ###*
     * Convenience method that returns information for the specified term.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {string}     term
    ###
    getInfoFor: (editor, bufferPosition, term) ->
        functions = @service.getGlobalFunctions()

        return null unless functions and term of functions

        return functions[term]

    ###*
     * @inheritdoc
    ###
    isValid: (editor, bufferPosition, term) ->
        return if @getInfoFor(editor, bufferPosition, term)? then true else false

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, bufferPosition, term) ->
        info = @getInfoFor(editor, bufferPosition, term)

        if info?
            if info.filename?
                atom.workspace.open(info.filename, {
                    initialLine    : (info.startLine - 1),
                    searchAllPanes : true
                })

            else
                shell.openExternal(@config.get('php_documentation_base_urls').functions + info.name)
