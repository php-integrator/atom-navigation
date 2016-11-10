{Point, Range} = require 'atom'

module.exports =

##*
# Provides functionality to aid in dealing with scope descriptors.
##
class ScopeDescriptorHelper
    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {Number}     climbCount
     *
     * @return {Array}
    ###
    getClassListForBufferPosition: (editor, bufferPosition, climbCount = 1) ->
        scopesArray = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopesArray()

        return [] if not scopesArray?
        return [] if climbCount > scopesArray.length

        classes = scopesArray[scopesArray.length - climbCount]

        return [] if not classes?

        return classes.split('.')

    ###*
     * Skips the scope descriptor at the specified location, returning the class list of the next one.
     *
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     * @param {Number}     climbCountForPosition
     *
     * @return {Array}
    ###
    getClassListFollowingBufferPosition: (editor, bufferPosition, climbCountForPosition) ->
        classList = @getClassListForBufferPosition(editor, bufferPosition, climbCountForPosition)

        range = @getBufferRangeForClassListAtPosition(editor, classList, bufferPosition, 0)

        return [] if not range?

        ++range.end.column

        classList = @getClassListForBufferPosition(editor, range.end)

        return classList

    ###*
     * Retrieves the (inclusive) start buffer position of the specified class list.
     *
     * @param {TextEditor}  editor
     * @param {Array}       classList
     * @param {Point}       bufferPosition
     * @param {Number}      climbCount
     *
     * @return {Point|null}
    ###
    getStartOfClassListAtPosition: (editor, classList, bufferPosition, climbCount = 1) ->
        startPosition = null
        position = bufferPosition.copy()

        loop
            doLoop = false
            exitLoop = false
            currentClimbCount = climbCount

            if currentClimbCount == 0
                doLoop = true
                currentClimbCount = 1

            loop
                positionClassList = @getClassListForBufferPosition(editor, position, currentClimbCount)

                if positionClassList.length == 0
                    exitLoop = true
                    break

                break if @areArraysEqual(positionClassList, classList)

                if not doLoop
                    exitLoop = true
                    break

                currentClimbCount++

            break if exitLoop

            startPosition = editor.clipBufferPosition(position.copy())

            break if not @moveToPreviousValidBufferPosition(editor, position)

        return startPosition

    ###*
     * Retrieves the (exclusive) end buffer position of the specified class list.
     *
     * @param {TextEditor}  editor
     * @param {Array}       classList
     * @param {Point}       bufferPosition
     * @param {Number}      climbCount
     *
     * @return {Point|null}
    ###
    getEndOfClassListAtPosition: (editor, classList, bufferPosition, climbCount = 1) ->
        endPosition = null
        position = bufferPosition.copy()

        loop
            doLoop = false
            exitLoop = false
            currentClimbCount = climbCount

            if currentClimbCount == 0
                doLoop = true
                currentClimbCount = 1

            loop
                positionClassList = @getClassListForBufferPosition(editor, position, currentClimbCount)

                if positionClassList.length == 0
                    exitLoop = true
                    break

                break if @areArraysEqual(positionClassList, classList)

                if not doLoop
                    exitLoop = true
                    break

                currentClimbCount++

            break if exitLoop

            endPosition = editor.clipBufferPosition(position.copy())

            break if not @moveToNextValidBufferPosition(editor, position)

        # Make the end exclusive
        if endPosition?
            endPosition.column++

        return endPosition

    ###*
     * @param {TextEditor}  editor
     * @param {Array}       classList
     * @param {Point}       bufferPosition
     * @param {Number}      climbCount
     *
     * @return {Range|null}
    ###
    getBufferRangeForClassListAtPosition: (editor, classList, bufferPosition, climbCount = 1) ->
        start = @getStartOfClassListAtPosition(editor, classList, bufferPosition, climbCount)
        end = @getEndOfClassListAtPosition(editor, classList, bufferPosition, climbCount)

        return null if not start?
        return null if not end?

        range = new Range(start, end)

        return range

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {Boolean}
    ###
    moveToPreviousValidBufferPosition: (editor, bufferPosition) ->
        return false if bufferPosition.row == 0 and bufferPosition.column == 0

        if bufferPosition.column > 0
            bufferPosition.column--

        else
            bufferPosition.row--

            lineText = editor.lineTextForBufferRow(bufferPosition.row)

            if lineText?
                bufferPosition.column = Math.max(lineText.length - 1, 0)

            else
                bufferPosition.column = 0

        return true

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
     *
     * @return {Boolean}
    ###
    moveToNextValidBufferPosition: (editor, bufferPosition) ->
        lastBufferPosition = editor.clipBufferPosition([Infinity, Infinity])

        return false if bufferPosition.row == lastBufferPosition.row and bufferPosition.column == lastBufferPosition.column

        lineText = editor.lineTextForBufferRow(bufferPosition.row)

        if lineText?
            lineLength = lineText.length

        else
            lineLength = 0

        if bufferPosition.column < lineLength
            bufferPosition.column++

        else
            bufferPosition.row++
            bufferPosition.column = 0

        return true

    ###*
     * @param {Array} left
     * @param {Array} right
     *
     * @return {Boolean}
    ###
    areArraysEqual: (left, right) ->
        return false if left.length != right.length

        for i in [0 .. left.length - 1]
            if left[i] != right[i]
                return false

        return true
