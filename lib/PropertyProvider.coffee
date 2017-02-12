{Point, Range} = require 'atom'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for member properties.
##
class PropertyProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        return false if 'php' not in classList
        return true if 'property' in classList

        # Ensure the dollar sign is also seen as a match
        if 'punctuation' in classList and 'definition' in classList and 'variable' in classList
            classList = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition)

        return true if 'variable' in classList and 'other' in classList and 'class' in classList

        return false

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition)

        if 'punctuation' in classList and 'definition' in classList and 'variable' in classList
            positionAfterBufferPosition = bufferPosition.copy()
            positionAfterBufferPosition.column++

            classList = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition)

            staticPropertyRange = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, positionAfterBufferPosition)

            range = range.union(staticPropertyRange)

        else # if it is a static property (but not its leading dollar sign)
            prefixRange = new Range(
                new Point(range.start.row, range.start.column - 1),
                new Point(range.start.row, range.start.column - 0)
            )

            prefixText = editor.getTextInBufferRange(prefixRange)

            if prefixText == '$'
                range.start.column--

        return range

    ###*
     * Convenience method that returns information for the specified term.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {String}     term
     *
     * @return {Promise}
    ###
    getInfoFor: (editor, bufferPosition, term) ->
        successHandler = (members) =>
            return null unless members.length > 0

            member = members[0]

            return null unless member.declaringStructure.filename

            return member

        failureHandler = () ->
            # Do nothing.

        return @getClassPropertiesAt(editor, bufferPosition, term).then(successHandler, failureHandler)

    ###*
     * Returns the class properties used at the specified location.
     *
     * @param {TextEditor} editor         The text editor to use.
     * @param {Point}      bufferPosition The cursor location of the member.
     * @param {String}     name           The name of the member to retrieve information about.
     *
     * @return {Promise}
    ###
    getClassPropertiesAt: (editor, bufferPosition, name) ->
        if not @isUsingProperty(editor, bufferPosition)
            return new Promise (resolve, reject) ->
                resolve(null)

        successHandler = (types) =>
            promises = []

            for type in types
                promises.push @getClassProperty(type, name)

            return Promise.all(promises)

        failureHandler = () ->
            # Do nothing.

        return @service.getResultingTypesAt(editor, bufferPosition, true).then(successHandler, failureHandler)

    ###*
     * Retrieves information about the specified property of the specified class.
     *
     * @param {String} className The full name of the class to examine.
     * @param {String} name      The name of the property to retrieve information about.
     *
     * @return {Promise}
    ###
    getClassProperty: (className, name) ->
        successHandler = (classInfo) =>
            if name of classInfo.properties
                return classInfo.properties[name]

        failureHandler = () ->
            # Do nothing.

        return @service.getClassInfo(className).then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    handleSpecificNavigation: (editor, range, text) ->
        successHandler = (info) =>
            return if not info?

            atom.workspace.open(info.declaringStructure.filename, {
                initialLine    : (info.declaringStructure.startLineMember - 1),
                searchAllPanes : true
            })

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(editor, range.start, text).then(successHandler, failureHandler)

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
