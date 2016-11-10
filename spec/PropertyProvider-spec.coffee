{Point} = require 'atom'

PropertyProvider = require '../lib/PropertyProvider'
ScopeDescriptorHelper = require '../lib/ScopeDescriptorHelper'

describe "PropertyProvider", ->
    editor = null
    grammar = null
    provider = new PropertyProvider(new ScopeDescriptorHelper())

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

    it "returns the correct results for non-static property access", ->
        source =
            '''
            <?php

            $test = $this->foo;
            '''

        editor.setText(source)

        line = 2
        startColumn = 15
        endColumn = 17

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

    it "returns the correct results for static property access", ->
        source =
            '''
            <?php

            $test = \\Some\\Namespace\\SomeClass::$foo;
            '''

        editor.setText(source)

        line = 2
        startColumn = 35
        endColumn = 38

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
