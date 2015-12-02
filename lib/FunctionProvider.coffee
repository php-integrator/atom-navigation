AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global functions.
##
class FunctionProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.function-call:not(.object):not(.static)'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.function-call:not(.object):not(.static)'

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        functions = @service.getGlobalFunctions()

        return unless functions and term of functions
        return unless functions[term].filename

        atom.workspace.open(functions[term].filename, {
            initialLine    : (functions[term].startLine - 1),
            searchAllPanes : true
        })
