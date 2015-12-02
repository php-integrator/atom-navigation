AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for constants.
##
class ConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.constant.other.class'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.constant.other.class'

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        bufferPosition = editor.getCursorBufferPosition()

        member = @service.getClassMemberAt(editor, bufferPosition, term)

        return unless member
        return unless member.declaringStructure.filename

        atom.workspace.open(member.declaringStructure.filename, {
            initialLine    : (member.declaringStructure.startLineMember - 1),
            searchAllPanes: true
        })
