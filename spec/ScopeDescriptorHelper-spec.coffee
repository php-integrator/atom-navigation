{Point} = require 'atom'

ScopeDescriptorHelper = require '../lib/ScopeDescriptorHelper'

describe "ScopeDescriptorHelper", ->
    editor = null
    grammar = null
    helper = new ScopeDescriptorHelper()

    beforeEach ->
        waitsForPromise ->
            atom.workspace.open().then (result) ->
                editor = result

        waitsForPromise ->
            atom.packages.activatePackage('language-php')

        runs ->
            grammar = atom.grammars.selectGrammar('.text.html.php')

        waitsFor ->
            grammar and editor

        runs ->
            editor.setGrammar(grammar)

    it "getStartOfClassListAtPosition returns the range of a class list", ->
        source =
            '''
            <?php

            $test = 'string';
            '''

        editor.setText(source)

        classList = ['meta', 'string-contents', 'quoted', 'single', 'php']

        line = 2
        startColumn = 9
        endColumn = 14

        for i in [startColumn .. endColumn]
            bufferPosition = new Point(2, i)

            range = helper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition, 1)

            expect(range).toBeTruthy()

            # NOTE: The quotation marks have a different scope descriptor than the actual string contents, so they are not
            # included in the range.
            expect(range.start.row).toEqual(2)
            expect(range.start.column).toEqual(startColumn)

            expect(range.end.row).toEqual(2)
            expect(range.end.column).toEqual(endColumn + 1)

    it "getStartOfClassListAtPosition moves up in the scope list if requested", ->
        source =
            '''
            <?php

            $test = \\Some\\Namespace\\CONST_TEST;
            '''

        editor.setText(source)

        classList = ['support', 'other', 'namespace', 'php']

        line = 2
        startColumn = 8
        endColumn = 23

        for i in [startColumn .. endColumn]
            bufferPosition = new Point(2, i)

            range = helper.getBufferRangeForClassListAtPosition(editor, classList, bufferPosition, 0)

            expect(range).toBeTruthy()

            # NOTE: The quotation marks have a different scope descriptor than the actual string contents, so they are not
            # included in the range.
            expect(range.start.row).toEqual(2)
            expect(range.start.column).toEqual(startColumn)

            expect(range.end.row).toEqual(2)
            expect(range.end.column).toEqual(endColumn + 1)
