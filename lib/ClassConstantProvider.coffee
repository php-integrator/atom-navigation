AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for class constants.
##
class ClassConstantProvider extends AbstractProvider
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

        try
            member = @service.getClassConstantAt(editor, bufferPosition, term)

        catch error
            return

        return unless member
        return unless member.declaringStructure.filename

        atom.workspace.open(member.declaringStructure.filename, {
            initialLine    : (member.declaringStructure.startLineMember - 1),
            searchAllPanes: true
        })
