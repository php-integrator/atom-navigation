AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for class constants.
##
class ClassConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    eventSelectors: '.constant.other.class'

    ###*
     * Convenience method that returns information for the specified term.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {string}     term
    ###
    getInfoFor: (editor, bufferPosition, term) ->
        member = @getClassConstantAt(editor, bufferPosition, term)

        return null unless member
        return null unless member.declaringStructure.filename

        return member

    ###*
     * Returns the class constant used at the specified location.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {string}     term
     *
     * @return {Object|null}
    ###
    getClassConstantAt: (editor, bufferPosition, term) ->
        try
            className = @service.getResultingTypeAt(editor, bufferPosition, true)

            return null unless className

            classInfo = @service.getClassInfo(className)

            if term of classInfo.constants
                return classInfo.constants[term]

        catch error
            return null

        return null

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
            atom.workspace.open(info.declaringStructure.filename, {
                initialLine    : (info.declaringStructure.startLineMember - 1),
                searchAllPanes: true
            })
