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
        classList = @getClassListForBufferPosition(editor, bufferPosition)

        return true if 'constant'  in classList and 'class' not in classList
        return true if 'namespace' in classList and 'constant' in @getClassListFollowingBufferPosition(editor, bufferPosition)

        return false

    ###*
     * @inheritdoc
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition)

        range = editor.bufferRangeForScopeAtPosition(classList.join('.'), bufferPosition)

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
                prefixClassList = @getClassListForBufferPosition(editor, prefixRange.start)

                if "namespace" in prefixClassList
                    namespaceRange = editor.bufferRangeForScopeAtPosition(prefixClassList.join('.'), prefixRange.start)

                else
                    namespaceRange = range
                    namespaceRange.start.column--

                range = namespaceRange.union(range)

        else if 'namespace' in classList
            suffixClassList = @getClassListFollowingBufferPosition(editor, bufferPosition)

            # Expand the range to include the constant name, if present.
            if 'constant' in suffixClassList
                constantRange = editor.bufferRangeForScopeAtPosition(suffixClassList.join('.'), new Point(range.end.row, range.end.column + 1))

                range = range.union(constantRange)

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
    handleSpecificNavigation: (editor, bufferPosition, text) ->
        successHandler = (info) =>
            return if not info?

            atom.workspace.open(info.filename, {
                initialLine    : (info.startLine - 1),
                searchAllPanes : true
            })

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(text).then(successHandler, failureHandler)
