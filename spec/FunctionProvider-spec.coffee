{Point} = require 'atom'

FunctionProvider = require '../lib/FunctionProvider'
ScopeDescriptorHelper = require '../lib/ScopeDescriptorHelper'

describe "FunctionProvider", ->
    editor = null
    grammar = null
    provider = new FunctionProvider(new ScopeDescriptorHelper())

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

    it "returns the correct results for user-defined namespaced functions", ->
        source =
            '''
            <?php

            $test = \\Some\\Namespace\\someFunction();
            '''

        editor.setText(source)

        line = 2
        startColumn = 8
        endColumn = 35

        for i in [startColumn .. endColumn]
            point = new Point(line, i)

            canProvide = provider.canProvideForBufferPosition(editor, point)

            expect(canProvide).toBeTruthy()

            range = provider.getRangeForBufferPosition(editor, point)

            expect(range).toBeTruthy()

            expect(range.start.row).toEqual(line)
            expect(range.start.column).toEqual(startColumn)

            expect(range.end.row).toEqual(line)
            expect(range.end.column).toEqual(endColumn + 1)

    it "returns the correct results for built-in functions", ->
        source =
            '''
            <?php

            $test = \\array_walk();
            '''

        editor.setText(source)

        line = 2
        startColumn = 8
        endColumn = 18

        for i in [startColumn .. endColumn]
            point = new Point(line, i)

            canProvide = provider.canProvideForBufferPosition(editor, point)

            expect(canProvide).toBeTruthy()

            range = provider.getRangeForBufferPosition(editor, point)

            expect(range).toBeTruthy()

            expect(range.start.row).toEqual(line)
            expect(range.start.column).toEqual(startColumn)

            expect(range.end.row).toEqual(line)
            expect(range.end.column).toEqual(endColumn + 1)
