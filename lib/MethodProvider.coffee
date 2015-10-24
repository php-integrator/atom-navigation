AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for member methods.
##
class MethodProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.function-call'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.function-call'

    ###*
     * @inheritdoc
    ###
    gotoRegex: /^(\$\w+)?((->|::)\w+\()+/

    ###*
     * @inheritdoc
    ###
    getJumpToRegex: (term) ->
        return ///function\ +#{term}(\ +|\()///i

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        bufferPosition = editor.getCursorBufferPosition()

        member = @service.getClassMemberAt(editor, bufferPosition, term)

        return unless member

        atom.workspace.open(member.declaringStructure.filename, {
            initialLine    : (member.startLine - 1),
            searchAllPanes : true
        })
