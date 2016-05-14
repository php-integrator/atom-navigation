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
    eventSelectors: '.function-call.object, .function-call.static'

    ###*
     * Convenience method that returns information for the specified term.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {string}     term
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
     * @param {string}     name           The name of the member to retrieve information about.
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
     * @param {string} className The full name of the class to examine.
     * @param {string} name      The name of the method to retrieve information about.
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
    isValid: (editor, bufferPosition, term) ->
        successHandler = (info) =>
            return if info then true else false

        failureHandler = () ->
            return false

        @getInfoFor(editor, bufferPosition, term).then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, bufferPosition, term) ->
        successHandler = (info) =>
            return if not info?

            if info.declaringStructure.filename?
                atom.workspace.open(info.declaringStructure.filename, {
                    initialLine    : (info.declaringStructure.startLineMember - 1),
                    searchAllPanes : true
                })

            else
                shell.openExternal(@config.get('php_documentation_base_urls').classes + info.declaringStructure.name + '.' + info.name)

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(editor, bufferPosition, term).then(successHandler, failureHandler)

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
