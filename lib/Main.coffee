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
            ScopeDescriptorHelper = require './ScopeDescriptorHelper'
            HyperclickProviderDispatcher = require './HyperclickProviderDispatcher'

            @hyperclickProviderDispatcher = new HyperclickProviderDispatcher()

            scopeDescriptorHelper = new ScopeDescriptorHelper()

            ClassProvider         = require './ClassProvider'
            MethodProvider        = require './MethodProvider'
            PropertyProvider      = require './PropertyProvider'
            FunctionProvider      = require './FunctionProvider'
            ConstantProvider      = require './ConstantProvider'
            ClassConstantProvider = require './ClassConstantProvider'

            @hyperclickProviderDispatcher.addProvider(new ClassProvider(scopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new MethodProvider(scopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new PropertyProvider(scopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new FunctionProvider(scopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new ClassConstantProvider(scopeDescriptorHelper))
            @hyperclickProviderDispatcher.addProvider(new ConstantProvider(scopeDescriptorHelper))

        return @hyperclickProviderDispatcher

    ###*
     * @return {HyperclickProviderDispatcher}
    ###
    getHyperclickProvider: () ->
        return @getHyperclickProviderDispatcher()
