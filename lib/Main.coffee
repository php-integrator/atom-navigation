{Disposable} = require 'atom'

ClassProvider         = require './ClassProvider'
MethodProvider        = require './MethodProvider'
PropertyProvider      = require './PropertyProvider'
FunctionProvider      = require './FunctionProvider'
ConstantProvider      = require './ConstantProvider'
ClassConstantProvider = require './ClassConstantProvider'

module.exports =
    ###*
     * List of tooltip providers.
    ###
    providers: []

    ###*
     * Activates the package.
    ###
    activate: ->

    ###*
     * Deactivates the package.
    ###
    deactivate: ->
        @deactivateProviders()

    ###*
     * Activates the providers using the specified service.
    ###
    activateProviders: (service) ->
        @providers = []
        @providers.push new ClassProvider()
        @providers.push new MethodProvider()
        @providers.push new PropertyProvider()
        @providers.push new FunctionProvider()

        # The selector from the constant provider will still match class constants due to the way SubAtom does its
        # class selector checks. However, the reverse doesn't hold so if we add the class constant provider first,
        # we will not run into problems.
        @providers.push new ClassConstantProvider()
        @providers.push new ConstantProvider()

        for provider in @providers
            provider.activate(service)

    ###*
     * Deactivates any active providers.
    ###
    deactivateProviders: () ->
        for provider in @providers
            provider.deactivate()

        @providers = []

    ###*
     * Sets the php-integrator service.
     *
     * @param {mixed} service
    ###
    setService: (service) ->
        @activateProviders(service)

        return new Disposable => @deactivateProviders()
