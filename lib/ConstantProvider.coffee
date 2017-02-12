{Point, Range} = require 'atom'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global constants.
##
class ConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        return false if 'php' not in classList
        return true if 'constant'  in classList and 'class' not in classList
        return true if 'namespace' in classList and 'constant' in @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition)

        if 'punctuation' in classList
            originalClassList = classList
            classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition, 2)

            if 'namespace' in classList
                climbCount = 1

                if 'punctuation' in originalClassList
                    climbCount = 2

                return true if 'constant' in @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition, climbCount)

        return false

    ###*
     * @inheritdoc
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        originalClassList = classList

        if 'punctuation' in classList
            classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition, 2)

        range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition, 0)

        if 'constant' in classList
            prefixRange = new Range(
                new Point(range.start.row, range.start.column - 2),
                new Point(range.start.row, range.start.column - 0)
            )

            # Expand the range to include the namespace prefix, if present. We use two positions before the constant as
            # the slash itself sometimes has a "punctuation" class instead of a "namespace" class or, if it is alone, no
            # class at all.
            prefixText = editor.getTextInBufferRange(prefixRange)

            if prefixText.endsWith("\\")
                prefixClassList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, prefixRange.start)

                if "namespace" in prefixClassList
                    namespaceRange = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, prefixClassList, prefixRange.start, 0)

                else
                    namespaceRange = range
                    namespaceRange.start.column--

                range = namespaceRange.union(range)

        else if 'namespace' in classList
            climbCount = 1

            if 'punctuation' in originalClassList
                climbCount = 2

            suffixClassList = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition, climbCount)

            # Expand the range to include the constant name, if present.
            if 'constant' in suffixClassList
                constantRange = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, suffixClassList, new Point(range.end.row, range.end.column + 1))

                range = range.union(constantRange)

        else
            return null

        return range

    ###*
     * @param {String} text
     *
     * @return {Promise}
    ###
    getInfoFor: (text) ->
        successHandler = (constants) =>
            if text?[0] != '\\'
                text = '\\' + text

            return null unless constants and text of constants
            return null unless constants[text].filename

            return constants[text]

        failureHandler = () ->
            # Do nothing.

        return @service.getGlobalConstants().then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    handleSpecificNavigation: (editor, range, text) ->
        failureHandler = () ->
            # Do nothing.

        resolveTypeHandler = (type) =>
            successHandler = (info) =>
                return if not info?

                atom.workspace.open(info.filename, {
                    initialLine    : (info.startLine - 1),
                    searchAllPanes : true
                })

            return @getInfoFor(type).then(successHandler, failureHandler)

        @service.resolveType(editor.getPath(), range.start.row + 1, text, 'constant').then(
            resolveTypeHandler,
            failureHandler
        )
