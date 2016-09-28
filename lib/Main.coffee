module.exports =
    ###*
     * The name of the package.
     *
     * @var {String}
    ###
    packageName: 'php-integrator-navigation'

    ###*
    * @var {HyperclickProviderDispatcher}
    ###
    hyperclickProviderDispatcher: null

    ###*
     * Activates the package.
    ###
    activate: () ->
        require('atom-package-deps').install(@packageName).then () =>
            # We're done!

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

            @hyperclickProviderDispatcher.addProvider(new ClassProvider())
            @hyperclickProviderDispatcher.addProvider(new MethodProvider())
            @hyperclickProviderDispatcher.addProvider(new PropertyProvider())
            @hyperclickProviderDispatcher.addProvider(new FunctionProvider())
            @hyperclickProviderDispatcher.addProvider(new ClassConstantProvider())
            @hyperclickProviderDispatcher.addProvider(new ConstantProvider())

        return @hyperclickProviderDispatcher

    ###*
     * @return {HyperclickProviderDispatcher}
    ###
    getHyperclickProvider: () ->
        return @getHyperclickProviderDispatcher()
