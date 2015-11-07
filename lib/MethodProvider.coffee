AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for member methods.
##
class MethodProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.function-call.object, .function-call.static'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.function-call.object, .function-call.static'

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
