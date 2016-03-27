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
     * @param {TextEditor} editor         The text editor to use.
     * @param {Point}      bufferPosition The cursor location of the member.
     * @param {string}     name           The name of the member to retrieve information about.
     *
     * @return {Object|null}
    ###
    getClassConstantAt: (editor, bufferPosition, name) ->
        className = @service.getResultingTypeAt(editor, bufferPosition, true)

        return @getClassConstant(className, name)

    ###*
     * Retrieves information about the specified constant of the specified class.
     *
     * @param {string} className The full name of the class to examine.
     * @param {string} name      The name of the constant to retrieve information about.
     *
     * @return {Object|null}
    ###
    getClassConstant: (className, name) ->
        try
            classInfo = @service.getClassInfo(className)

        catch
            return null

        if name of classInfo.constants
            return classInfo.constants[name]

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
