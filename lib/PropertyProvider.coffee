AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for member properties.
##
class PropertyProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    eventSelectors: '.property'

    ###*
     * Convenience method that returns information for the specified term.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {string}     term
    ###
    getInfoFor: (editor, bufferPosition, term) ->
        try
            member = @getClassPropertyAt(editor, bufferPosition, term)

        catch error
            return null

        return null unless member
        return null unless member.declaringStructure.filename

        return member

    ###*
     * Returns the class property used at the specified location.
     *
     * @param {TextEditor} editor         The text editor to use.
     * @param {Point}      bufferPosition The cursor location of the member.
     * @param {string}     name           The name of the member to retrieve information about.
     *
     * @return {Object|null}
    ###
    getClassPropertyAt: (editor, bufferPosition, name) ->
        if not @isUsingProperty(editor, bufferPosition)
            return null

        className = @service.getResultingTypeAt(editor, bufferPosition, true)

        return @getClassProperty(className, name)

    ###*
     * Retrieves information about the specified property of the specified class.
     *
     * @param {string} className The full name of the class to examine.
     * @param {string} name      The name of the property to retrieve information about.
     *
     * @return {Object|null}
    ###
    getClassProperty: (className, name) ->
        try
            classInfo = @service.getClassInfo(className)

        catch
            return null

        if name of classInfo.properties
            return classInfo.properties[name]

        return null

    ###*
     * @example When querying "$this->test", using a position inside 'test' will return true.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {boolean}
    ###
    isUsingProperty: (editor, bufferPosition) ->
        scopeDescriptor = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopeChain()

        return (scopeDescriptor.indexOf('.property') != -1)

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
                searchAllPanes : true
            })
