AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for class constants.
##
class ClassConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        return false if 'php' not in classList
        return true if 'other' in classList and 'class' in classList

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
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {String}     text
     *
     * @return {Promise}
    ###
    getInfoFor: (editor, bufferPosition, text) ->
        successHandler = (members) =>
            return null unless members.length > 0

            member = members[0]

            return null unless member.declaringStructure.filename

            return member

        failureHandler = () ->
            # Do nothing.

        return @getClassConstantsAt(editor, bufferPosition, text).then(successHandler, failureHandler)

    ###*
     * Returns the class constants used at the specified location.
     *
     * @param {TextEditor} editor         The text editor to use.
     * @param {Point}      bufferPosition The cursor location of the member.
     * @param {String}     name           The name of the member to retrieve information about.
     *
     * @return {Promise}
    ###
    getClassConstantsAt: (editor, bufferPosition, name) ->
        successHandler = (types) =>
            promises = []

            for type in types
                promises.push @getClassConstant(type, name)

            return Promise.all(promises)

        failureHandler = () ->
            # Do nothing.

        return @service.getResultingTypesAt(editor, bufferPosition, true).then(successHandler, failureHandler)

    ###*
     * Retrieves information about the specified constant of the specified class.
     *
     * @param {String} className The full name of the class to examine.
     * @param {String} name      The name of the constant to retrieve information about.
     *
     * @return {Promise}
    ###
    getClassConstant: (className, name) ->
        successHandler = (classInfo) =>
            if name of classInfo.constants
                return classInfo.constants[name]

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
                searchAllPanes: true
            })

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(editor, range.start, text).then(successHandler, failureHandler)
