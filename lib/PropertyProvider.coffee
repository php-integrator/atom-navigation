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
    gotoFromWord: (editor, term) ->
        bufferPosition = editor.getCursorBufferPosition()

        try
            member = @service.getClassPropertyAt(editor, bufferPosition, term)

        catch error
            return

        return unless member
        return unless member.declaringStructure.filename

        atom.workspace.open(member.declaringStructure.filename, {
            initialLine    : (member.declaringStructure.startLineMember - 1),
            searchAllPanes: true
        })
