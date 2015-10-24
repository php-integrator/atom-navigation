
module.exports =
    ###*
     * Gets the full words from the buffer position given.
     * E.g. Getting a class with its namespace.
     * @param  {TextEditor}     editor   TextEditor to search.
     * @param  {BufferPosition} position BufferPosition to start searching from.
     * @return {string}  Returns a string of the class.
    ###
    getFullWordFromBufferPosition: (editor, position) ->
        foundStart = false
        foundEnd = false
        startBufferPosition = []
        endBufferPosition = []
        forwardRegex = /-|(?:\()[\w\[\$\(\\]|\s|\)|;|'|,|"|\|/
        backwardRegex = /\(|\s|\)|;|'|,|"|\|/
        index = -1
        previousText = ''

        loop
            index++
            startBufferPosition = [position.row, position.column - index - 1]
            range = [[position.row, position.column], [startBufferPosition[0], startBufferPosition[1]]]
            currentText = editor.getTextInBufferRange(range)
            if backwardRegex.test(editor.getTextInBufferRange(range)) || startBufferPosition[1] == -1 || currentText == previousText
                foundStart = true
            previousText = editor.getTextInBufferRange(range)
            break if foundStart
        index = -1
        loop
            index++
            endBufferPosition = [position.row, position.column + index + 1]
            range = [[position.row, position.column], [endBufferPosition[0], endBufferPosition[1]]]
            currentText = editor.getTextInBufferRange(range)
            if forwardRegex.test(currentText) || endBufferPosition[1] == 500 || currentText == previousText
                foundEnd = true
            previousText = editor.getTextInBufferRange(range)
            break if foundEnd

        startBufferPosition[1] += 1
        endBufferPosition[1] -= 1
        return editor.getTextInBufferRange([startBufferPosition, endBufferPosition])

    ###*
     * Finds the buffer position of the word given
     * @param  {TextEditor} editor TextEditor to search
     * @param  {string}     term   The function name to search for
     * @return {mixed}             Either null or the buffer position of the function.
    ###
    findBufferPositionOfWord: (editor, term, regex, line = null) ->
        if line != null
            lineText = editor.lineTextForBufferRow(line)
            result = @checkLineForWord(lineText, term, regex)
            if result != null
                return [line, result]
        else
            text = editor.getText()
            row = 0
            lines = text.split('\n')
            for line in lines
                result = @checkLineForWord(line, term, regex)
                if result != null
                    return [row, result]
                row++
        return null;

    ###*
     * Checks the lineText for the term and regex matches
     * @param  {string}   lineText The line of text to check.
     * @param  {string}   term     Term to look for.
     * @param  {regex}    regex    Regex to run on the line to make sure it's valid
     * @return {null|int}          Returns null if nothing was found or an
     *                             int of the column the term is on.
    ###
    checkLineForWord: (lineText, term, regex) ->
        if regex.test(lineText)
            words = lineText.split(' ')
            propertyIndex = 0
            for element in words
                if element.indexOf(term) != -1
                    break
                propertyIndex++;

              reducedWords = words.slice(0, propertyIndex).join(' ')
              return reducedWords.length + 1
        return null
