shell = require 'shell'

{Point, Range} = require 'atom'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global functions.
##
class FunctionProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, ['meta', 'function-call', 'php'], bufferPosition, 0)

        return true if range?

        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        return false if 'php' not in classList

        return true if 'support' in classList and 'function' in classList

        if 'punctuation' in classList
            classListFollowingBufferPosition = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition)

            return true if 'support' in classListFollowingBufferPosition and 'function' in classListFollowingBufferPosition

        return false

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, ['meta', 'function-call', 'php'], bufferPosition, 0)

        if not range?
            # Built-in function.
            classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

            range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition)

            if 'punctuation' in classList
                # Include the function call after the leading slash.
                positionAfterBufferPosition = bufferPosition.copy()
                positionAfterBufferPosition.column++

                classList = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition)

                functionCallRange = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, positionAfterBufferPosition)

                range = range.union(functionCallRange)

            else # .support.function.*.php
                # Include a leading slash, if any.
                prefixRange = new Range(
                    new Point(range.start.row, range.start.column - 1),
                    new Point(range.start.row, range.start.column - 0)
                )

                prefixText = editor.getTextInBufferRange(prefixRange)

                if prefixText == '\\'
                    range.start.column--

        return range

    ###*
     * @param {String} text
     *
     * @return {Promise}
    ###
    getInfoFor: (text) ->
        successHandler = (functions) =>
            if text?[0] != '\\'
                text = '\\' + text

            return null unless functions and text of functions

            return functions[text]

        failureHandler = () ->
            # Do nothing.

        return @service.getGlobalFunctions().then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    handleSpecificNavigation: (editor, range, text) ->
        failureHandler = () ->
            # Do nothing.

        resolveTypeHandler = (type) =>
            successHandler = (info) =>
                return if not info?

                if info.filename?
                    atom.workspace.open(info.filename, {
                        initialLine    : (info.startLine - 1),
                        searchAllPanes : true
                    })

                else
                    shell.openExternal(@service.getDocumentationUrlForFunction(info.name))

            return @getInfoFor(type).then(successHandler, failureHandler)

        @service.resolveType(editor.getPath(), range.start.row + 1, text, 'function').then(
            resolveTypeHandler,
            failureHandler
        )
