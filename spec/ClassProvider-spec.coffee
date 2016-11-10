{Point} = require 'atom'

ClassProvider = require '../lib/ClassProvider'
ScopeDescriptorHelper = require '../lib/ScopeDescriptorHelper'

describe "ClassProvider", ->
    editor = null
    grammar = null
    provider = new ClassProvider(new ScopeDescriptorHelper())

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

    it "returns the correct results for namespaced class names", ->
        source =
            '''
            <?php

            $test = new \\Some\\Namespace\\SomeClass();
            '''

        editor.setText(source)

        line = 2
        startColumn = 12
        endColumn = 36

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

    it "returns the correct results for built-in class names", ->
        source =
            '''
            <?php

            $test = new \\LogicException();
            '''

        editor.setText(source)

        line = 2
        startColumn = 12
        endColumn = 26

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

    it "returns the correct results for class names after the extends keyword", ->
        source =
            '''
            <?php

            class Test extends Controller
            {

            }
            '''

        editor.setText(source)

        line = 2
        startColumn = 19
        endColumn = 29

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

    it "returns the correct results for class names after the implements keyword", ->
        source =
            '''
            <?php

            class Test implements SomeInterface
            {

            }
            '''

        editor.setText(source)

        line = 2
        startColumn = 22
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

    it "returns the correct results for class names after use statements", ->
        source =
            '''
            <?php

            use \\Some\\Namespace\\SomeClass;
            '''

        editor.setText(source)

        line = 2
        startColumn = 4
        endColumn = 28

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

    it "returns the correct results in docblock @param statements", ->
        source =
            '''
            <?php

            /**
             * @param \\Some\\Namespace\\SomeClass $foo Description.
             */
            '''

        editor.setText(source)

        line = 3
        startColumn = 10
        endColumn = 34

        provider.setService({
            isBasicType: () ->
                return false
        })

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

    it "returns the correct results in docblock @var statements", ->
        source =
            '''
            <?php

            /**
             * @var \\Some\\Namespace\\SomeClass
             */
            '''

        editor.setText(source)

        line = 3
        startColumn = 8
        endColumn = 32

        provider.setService({
            isBasicType: () ->
                return false
        })

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

    it "returns the correct results in docblock @return statements", ->
        source =
            '''
            <?php

            /**
             * @return \\Some\\Namespace\\SomeClass as a test.
             */
            '''

        editor.setText(source)

        line = 3
        startColumn = 11
        endColumn = 35

        provider.setService({
            isBasicType: () ->
                return false
        })

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

    it "returns the correct results in docblock @throws statements", ->
        source =
            '''
            <?php

            /**
             * @throws \\Some\\Namespace\\SomeClass when something happens.
             */
            '''

        editor.setText(source)

        line = 3
        startColumn = 11
        endColumn = 35

        provider.setService({
            isBasicType: () ->
                return false
        })

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

    it "returns the correct results in docblock @see statements", ->
        source =
            '''
            <?php

            /**
             * @see \\Some\\Namespace\\SomeClass
             */
            '''

        editor.setText(source)

        line = 3
        startColumn = 8
        endColumn = 32

        provider.setService({
            isBasicType: () ->
                return false
        })

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

    it "returns the correct results in singe-line docblock statements ", ->
        source =
            '''
            <?php

            /** @var \\Some\\Namespace\\SomeClass[] */
            '''

        editor.setText(source)

        line = 2
        startColumn = 9
        endColumn = 33

        provider.setService({
            isBasicType: () ->
                return false
        })

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
