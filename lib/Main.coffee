module.exports =
    ###*
     * Configuration settings.
    ###
    config:
        navigationRequireAltKey:
            title       : 'Use the alt key for navigation'
            description : 'If set, the alt key will need to be held down in combination with a mouse click for
                           navigating. This stacks with the other modifiers.'
            type        : 'boolean'
            default     : true
            order       : 1

        navigationRequireMetaKey:
            title       : 'Use the meta key for navigation'
            description : 'If set, the meta key will need to be held down in combination with a mouse click for
                           navigating. This stacks with the other modifiers.'
            type        : 'boolean'
            default     : false
            order       : 2

        navigationRequireCtrlKey:
            title       : 'Use the ctrl key for navigation'
            description : 'If set, the ctrl key will need to be held down in combination with a mouse click for
                           navigating. This stacks with the other modifiers.'
            type        : 'boolean'
            default     : false
            order       : 3

        navigationRequireShiftKey:
            title       : 'Use the shift key for navigation'
            description : 'If set, the shift key will need to be held down in combination with a mouse click for
                           navigating. This stacks with the other modifiers.'
            type        : 'boolean'
            default     : false
            order       : 4

    ###*
     * The name of the package.
    ###
    packageName: 'php-integrator-navigation'

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
        AtomConfig            = require './AtomConfig'
        ClassProvider         = require './ClassProvider'
        MethodProvider        = require './MethodProvider'
        PropertyProvider      = require './PropertyProvider'
        FunctionProvider      = require './FunctionProvider'
        ConstantProvider      = require './ConstantProvider'
        ClassConstantProvider = require './ClassConstantProvider'

        @configuration = new AtomConfig(@packageName)

        @providers = []
        @providers.push new ClassProvider(@configuration)
        @providers.push new MethodProvider(@configuration)
        @providers.push new PropertyProvider(@configuration)
        @providers.push new FunctionProvider(@configuration)
        @providers.push new ClassConstantProvider(@configuration)
        @providers.push new ConstantProvider(@configuration)

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

        {Disposable} = require 'atom'

        return new Disposable => @deactivateProviders()
