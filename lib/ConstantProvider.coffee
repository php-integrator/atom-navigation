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
    getJumpToRegex: (term) ->
        return ///const\s+#{term}///

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        bufferPosition = editor.getCursorBufferPosition()

        member = @service.getClassMemberAt(editor, bufferPosition, term)

        return unless member
        return unless member.declaringStructure.filename

        @jumpWord = term

        if member.declaringStructure.filename == editor.getPath()
            @jumpTo(editor, term, false)

        atom.workspace.open(member.declaringStructure.filename, {
            searchAllPanes: true
        })
