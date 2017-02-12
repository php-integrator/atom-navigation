shell = require 'shell'

{Point, Range} = require 'atom'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for classes (i.e. being able to click class, interface and trait names to navigate to them).
##
class ClassProvider extends AbstractProvider
    ###*
     * A list of all markers that have been placed inside comments to allow code navigation there as well.
     *
     * @var {Object}
    ###
    markers: null

    ###*
     * @inheritdoc
    ###
    canProvideForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        return false if 'php' not in classList

        climbCount = 1

        if 'punctuation' in classList and 'inheritance' in classList
            classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition, 2)

            climbCount = 2

        return true if 'class' in classList and 'support' in classList
        return true if 'inherited-class' in classList
        return true if 'namespace' in classList and 'use' in classList
        return true if 'phpdoc' in classList
        return true if 'comment' in classList # See also https://github.com/atom/language-php/issues/135

        if 'namespace' in classList
            classListFollowingBufferPosition = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition, climbCount)

            return true if ('class' in classListFollowingBufferPosition and 'support' in classListFollowingBufferPosition) or 'inherited-class' in classListFollowingBufferPosition

        return false

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getRangeForBufferPosition: (editor, bufferPosition) ->
        classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition)

        climbCount = 1

        if 'punctuation' in classList and 'inheritance' in classList
            classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, bufferPosition, 2)

            climbCount = 2

        range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition, 0)

        # Atom's consistency regarding the namespace separator splitting a namespace prefix and an actual class name
        # leaves something to be desired: sometimes it's part of the namespace, other times it's in its own class,
        # in even other cases it has no class at all. For some reason fetching the range for the scope also returns
        # "undefined". This entire if-block exists only to handle this corner case.
        if not range?
            newBufferPosition = bufferPosition.copy()
            --newBufferPosition.column

            classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, newBufferPosition)

            if 'punctuation' in classList and 'inheritance' in classList
                classList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, newBufferPosition, 2)

            range = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, classList, newBufferPosition)

            ++bufferPosition.column

        if ('class' in classList and 'support' in classList) or 'inherited-class' in classList
            prefixRange = new Range(
                new Point(range.start.row, range.start.column - 1),
                new Point(range.start.row, range.start.column - 0)
            )

            prefixText = editor.getTextInBufferRange(prefixRange)

            if prefixText == "\\"
                prefixClassList = @scopeDescriptorHelper.getClassListForBufferPosition(editor, prefixRange.start, 2)

                if "namespace" in prefixClassList
                    namespaceRange = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, prefixClassList, prefixRange.start, 0)

                else
                    namespaceRange = range
                    namespaceRange.start.column--

                if namespaceRange?
                    range = namespaceRange.union(range)

        else if 'namespace' in classList
            suffixClassList = @scopeDescriptorHelper.getClassListFollowingBufferPosition(editor, bufferPosition, climbCount)

            # Expand the range to include the constant name, if present.
            if ('class' in suffixClassList and 'support' in suffixClassList) or 'inherited-class' in suffixClassList
                classNameRange = @scopeDescriptorHelper.getBufferRangeForClassListAtPosition(editor, suffixClassList, new Point(range.end.row, range.end.column + 1))

                if classNameRange?
                    range = range.union(classNameRange)

        else if 'phpdoc' in classList or 'comment' in classList
            # Docblocks are seen as one entire region of text as they don't have syntax highlighting. Use regular
            # expressions instead to find interesting parts containing class names.
            lineText = editor.lineTextForBufferRow(bufferPosition.row)

            ranges = []

            if /@param|@var|@return|@throws|@see/g.test(lineText)
                ranges = @getRangesForDocblockLine(lineText.split(' '), parseInt(bufferPosition.row), editor, true, 0, 0, false)

            else if /@\\?([A-Za-z0-9_]+)\\?([A-Za-zA-Z_\\]*)?/g.test(lineText)
                ranges = @getRangesForDocblockLine(lineText.split(' '), parseInt(bufferPosition.row), editor, true, 0, 0, true)

            for range in ranges
                if range.containsPoint(bufferPosition)
                    return range

            return null

        return range

    ###*
     * @param {Array}      words        The array of words to check.
     * @param {Number}     rowIndex     The current row the words are on within the editor.
     * @param {TextEditor} editor       The editor the words are from.
     * @param {bool}       shouldBreak  Flag to say whether the search should break after finding 1 class.
     * @param {Number}     currentIndex The current column index the search is on.
     * @param {Number}     offset       Any offset that should be applied when creating the marker.
    ###
    getRangesForDocblockLine: (words, rowIndex, editor, shouldBreak, currentIndex = 0, offset = 0, isAnnotation = false) ->
        if isAnnotation
            regex = /^@(\\?(?:[A-Za-z0-9_]+)\\?(?:[A-Za-zA-Z_\\]*)?)/g

        else
            regex = /^(\\?(?:[A-Za-z0-9_]+)\\?(?:[A-Za-zA-Z_\\]*)?)/g

        ranges = []

        for key,value of words
            continue if value.length == 0

            newValue = value.match(regex)

            if newValue? && @service.isBasicType(value) == false
                newValue = newValue[0]

                if value.includes('|')
                    ranges = ranges.concat(@getRangesForDocblockLine(value.split('|'), rowIndex, editor, false, currentIndex, parseInt(key)))

                else
                    if isAnnotation
                        newValue = newValue.substr(1)
                        currentIndex += 1

                    range = new Range(
                        new Point(rowIndex, currentIndex + parseInt(key) + offset),
                        new Point(rowIndex, currentIndex + parseInt(key) + newValue.length + offset)
                    )

                    ranges.push(range)

                if shouldBreak == true
                    break

            currentIndex += value.length;

        return ranges

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
        if not term
            return new Promise (resolve, reject) ->
                resolve(null)

        failureHandler = () ->
            # Do nothing.

        scopeChain = editor.scopeDescriptorForBufferPosition(bufferPosition).getScopeChain()

        # Don't attempt to resolve class names in use statements.
        if scopeChain.indexOf('.support.other.namespace.use') != -1
            successHandler = (currentClassName) =>
                # Scope descriptors for trait use statements and actual "import" use statements are the same, so we
                # have no choice but to use class information for this.
                if not currentClassName?
                    return false

                return true

            firstPromise = @service.determineCurrentClassName(editor, bufferPosition).then(successHandler, failureHandler)

        else
            firstPromise = new Promise (resolve, reject) ->
                resolve(true)

        successHandler = (doResolve) =>
            promise = null
            className = term

            if doResolve
                promise = @service.resolveTypeAt(editor, bufferPosition, className, 'classlike')

            else
                promise = new Promise (resolve, reject) ->
                    resolve(className)

            nestedSuccessHandler = (className) =>
                return @service.getClassInfo(className)

            return promise.then(nestedSuccessHandler, failureHandler)

        return firstPromise.then(successHandler, failureHandler)

    ###*
     * @inheritdoc
    ###
    handleSpecificNavigation: (editor, range, text) ->
        successHandler = (info) =>
            return if not info?

            if info.filename?
                atom.workspace.open(info.filename, {
                    initialLine    : (info.startLine - 1),
                    searchAllPanes : true
                })

            else
                shell.openExternal(@service.getDocumentationUrlForClass(info.name))

        failureHandler = () ->
            # Do nothing.

        @getInfoFor(editor, range.start, text).then(successHandler, failureHandler)
