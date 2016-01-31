Config = require './Config'

module.exports =

##*
# Config that retrieves its settings from Atom's config.
##
class AtomConfig extends Config
    ###*
     * The name of the package to use when searching for settings.
    ###
    packageName: null

    ###*
     * @inheritdoc
    ###
    constructor: (@packageName) ->
        super()

        @attachListeners()

    ###*
     * @inheritdoc
    ###
    load: () ->
        @set('navigationRequireAltKey', atom.config.get("#{@packageName}.navigationRequireAltKey"))
        @set('navigationRequireMetaKey', atom.config.get("#{@packageName}.navigationRequireMetaKey"))
        @set('navigationRequireCtrlKey', atom.config.get("#{@packageName}.navigationRequireCtrlKey"))
        @set('navigationRequireShiftKey', atom.config.get("#{@packageName}.navigationRequireShiftKey"))

    ###*
     * Attaches listeners to listen to Atom configuration changes.
    ###
    attachListeners: () ->
        atom.config.onDidChange "#{@packageName}.navigationRequireAltKey", () =>
            @set('navigationRequireAltKey', atom.config.get("#{@packageName}.navigationRequireAltKey"))

        atom.config.onDidChange "#{@packageName}.navigationRequireMetaKey", () =>
            @set('navigationRequireMetaKey', atom.config.get("#{@packageName}.navigationRequireMetaKey"))

        atom.config.onDidChange "#{@packageName}.navigationRequireCtrlKey", () =>
            @set('navigationRequireCtrlKey', atom.config.get("#{@packageName}.navigationRequireCtrlKey"))

        atom.config.onDidChange "#{@packageName}.navigationRequireShiftKey", () =>
            @set('navigationRequireShiftKey', atom.config.get("#{@packageName}.navigationRequireShiftKey"))
