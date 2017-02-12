shell = require 'shell'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for member methods.
##
class MethodProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        return false if 'php' not in classList
        return true if 'function-call' in classList and ('object' in classList or 'static' in classList)

        return false

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition)

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

            return member

        failureHandler = () ->
            # Do nothing.

        return @getClassMethodsAt(editor, bufferPosition, term).then(successHandler, failureHandler)

    ###*
     * Returns the class methods used at the specified location.
     *
     * @param {TextEditor} editor         The text editor to use.
     * @param {Point}      bufferPosition The cursor location of the member.
     * @param {String}     name           The name of the member to retrieve information about.
     *
     * @return {Promise}
    ###
    getClassMethodsAt: (editor, bufferPosition, name) ->
        if not @isUsingMethod(editor, bufferPosition)
            return new Promise (resolve, reject) ->
                resolve(null)

        successHandler = (types) =>
            promises = []

            for type in types
                promises.push @getClassMethod(type, name)

            return Promise.all(promises)

        failureHandler = () ->
            # Do nothing.

        return @service.getResultingTypesAt(editor, bufferPosition, true).then(successHandler, failureHandler)

    ###*
     * Retrieves information about the specified method of the specified class.
     *
     * @param {String} className The full name of the class to examine.
     * @param {String} name      The name of the method to retrieve information about.
     *
     * @return {Promise}
    ###
    getClassMethod: (className, name) ->
        successHandler = (classInfo) =>
            if name of classInfo.methods
                return classInfo.methods[name]

        failureHandler = () ->
            # Do nothing.

        return @service.getClassInfo(className).then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    handleSpecificNavigation: (editor, range, text) ->
        successHandler = (info) =>
            return if not info?

            if info.declaringStructure.filename?
                atom.workspace.open(info.declaringStructure.filename, {
                    initialLine    : (info.declaringStructure.startLineMember - 1),
                    searchAllPanes : true
                })

            else
                shell.openExternal(@service.getDocumentationUrlForClassMethod(info.declaringStructure.name, info.name))

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(editor, range.start, text).then(successHandler, failureHandler)

    ###*
     * @example When querying "$this->test()", using a position inside 'test' will return true.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {boolean}
    ###
    isUsingMethod: (editor, bufferPosition) ->
        scopeDescriptor = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopeChain()

        return (scopeDescriptor.indexOf('.property') == -1)
