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
            CachingScopeDescriptorHelper = require './CachingScopeDescriptorHelper'
            HyperclickProviderDispatcher = require './HyperclickProviderDispatcher'

            cachingScopeDescriptorHelper = new CachingScopeDescriptorHelper()

            @hyperclickProviderDispatcher = new HyperclickProviderDispatcher(cachingScopeDescriptorHelper)

            ClassProvider         = require './ClassProvider'
            MethodProvider        = require './MethodProvider'
            PropertyProvider      = require './PropertyProvider'
            FunctionProvider      = require './FunctionProvider'
            ConstantProvider      = require './ConstantProvider'
            ClassConstantProvider = require './ClassConstantProvider'

            @hyperclickProviderDispatcher.addProvider(new ClassProvider(cachingScopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new MethodProvider(cachingScopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new PropertyProvider(cachingScopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new FunctionProvider(cachingScopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new ClassConstantProvider(cachingScopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new ConstantProvider(cachingScopeDescriptorHelper))

        return @hyperclickProviderDispatcher

    ###*
     * @return {HyperclickProviderDispatcher}
    ###
    getHyperclickProvider: () ->
        return @getHyperclickProviderDispatcher()
