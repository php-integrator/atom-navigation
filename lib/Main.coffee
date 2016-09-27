module.exports =
    ###*
     * Configuration settings.
     *
     * @var {Object}
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
     *
     * @var {String}
    ###
    packageName: 'php-integrator-navigation'

    ###*
     * @var {AtomConfig}
    ###
    atomConfig: null

    ###*
    * @var {HyperclickProviderDispatcher}
    ###
    hyperclickProviderDispatcher: null

    ###*
     * Activates the package.
    ###
    activate: () ->

    ###*
     * Deactivates the package.
    ###
    deactivate: () ->

    ###*
     * Sets the php-integrator service.
     *
     * @param {mixed} service
    ###
    setService: (service) ->
        @getHyperclickProvider().setService(service)

    ###*
     * @return {AtomConfig}
    ###
    getAtomConfig: () ->
        if not @atomConfig
            AtomConfig = require './AtomConfig'

            @atomConfig = new AtomConfig(@packageName)

        return @atomConfig


    ###*
     * @return {HyperclickProviderDispatcher}
    ###
    getHyperclickProviderDispatcher: () ->
        if not @hyperclickProviderDispatcher
            HyperclickProviderDispatcher = require './HyperclickProviderDispatcher'

            @hyperclickProviderDispatcher = new HyperclickProviderDispatcher()

            ClassProvider         = require './ClassProvider'
            MethodProvider        = require './MethodProvider'
            PropertyProvider      = require './PropertyProvider'
            FunctionProvider      = require './FunctionProvider'
            ConstantProvider      = require './ConstantProvider'
            ClassConstantProvider = require './ClassConstantProvider'

            configuration = @getAtomConfig()

            @hyperclickProviderDispatcher.addProvider(new ClassProvider(configuration))
            @hyperclickProviderDispatcher.addProvider(new MethodProvider(configuration))
            @hyperclickProviderDispatcher.addProvider(new PropertyProvider(configuration))
            @hyperclickProviderDispatcher.addProvider(new FunctionProvider(configuration))
            @hyperclickProviderDispatcher.addProvider(new ClassConstantProvider(configuration))
            @hyperclickProviderDispatcher.addProvider(new ConstantProvider(configuration))

        return @hyperclickProviderDispatcher

    ###*
     * @return {HyperclickProviderDispatcher}
    ###
    getHyperclickProvider: () ->
        return @getHyperclickProviderDispatcher()
