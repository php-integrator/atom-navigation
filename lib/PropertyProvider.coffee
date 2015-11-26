AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for member properties.
##
class PropertyProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.property'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.property'

    ###*
     * @inheritdoc
    ###
    getJumpToRegex: (term) ->
        return ///(?:protected|public|private|static)\s+\$#{term}///

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        bufferPosition = editor.getCursorBufferPosition()

        try
            member = @service.getClassMemberAt(editor, bufferPosition, term)

        catch error
            return

        return unless member

        return unless member.declaringStructure.filename

        if member.isMagic
            atom.workspace.open(member.declaringStructure.filename, {
                initialLine    : (member.declaringStructure.startLine - 1),
                searchAllPanes : true
            })

        else
            @jumpWord = term

            if member.declaringStructure.filename == editor.getPath()
                @jumpTo(editor, term, false)

            atom.workspace.open(member.declaringStructure.filename, {
                searchAllPanes: true
            })
