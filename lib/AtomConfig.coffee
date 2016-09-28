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
        # @set('navigationRequireAltKey', atom.config.get("#{@packageName}.navigationRequireAltKey"))

    ###*
     * Attaches listeners to listen to Atom configuration changes.
    ###
    attachListeners: () ->
        # atom.config.onDidChange "#{@packageName}.navigationRequireAltKey", () =>
        #     @set('navigationRequireAltKey', atom.config.get("#{@packageName}.navigationRequireAltKey"))
