{Point} = require 'atom'

ConstantProvider = require '../lib/ConstantProvider'

describe "ConstantProvider", ->
    editor = null
    grammar = null
    provider = new ConstantProvider()

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

    it "returns the correct results", ->
        source =
            '''
            <?php

            $test = \\Some\\Namespace\\CONST_TEST;
            '''

        editor.setText(source)

        line = 2
        startColumn = 8
        endColumn = 33

        for i in [startColumn .. endColumn]
            point = new Point(line, i)

            canProvide = provider.canProvideForBufferPosition(editor, point)

            expect(canProvide).toBeTruthy()

            range = provider.getRangeForBufferPosition(editor, point)

            expect(range).toBeTruthy()

            expect(range.start.row).toEqual(2)
            expect(range.start.column).toEqual(8)

            expect(range.end.row).toEqual(2)
            expect(range.end.column).toEqual(34)

        lines = editor.getLineCount()