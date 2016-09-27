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
        classList = @getClassListForBufferPosition(editor, bufferPosition)

        return true if 'property' in classList

        return false

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition)

        range = editor.bufferRangeForScopeAtPosition(classList.join('.'), bufferPosition)

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
