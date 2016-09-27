{Point, Range} = require 'atom'

AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Dispatches a hyperclick request to the correct provider.
#
# Hyperclick only supports a single provider per package, so we have to figure out dispatching the request to the
# correct provider on our own.
##
class HyperclickProviderDispatcher extends AbstractProvider
    ###*
     * @var {Array}
    ###
    providers: null

    ###*
     * @var {Object}
    ###
    service: null

    ###*
     * Constructor.
    ###
    constructor: () ->
        @providers = []

    ###*
     * @param {AbstractProvider} provider
    ###
    addProvider: (provider) ->
        @providers.push(provider)

        provider.setService(@service)

    ###*
     * @param {Object} service
    ###
    setService: (service) ->
        @service = service

        for provider in @providers
            provider.setService(service)

    ###*
     * @param {TextEditor} editor
     * @param {Point}      bufferPosition
    ###
    getSuggestion: (editor, bufferPosition) ->
        rangeToHighlight = null
        interestedProviderInfoList = []

        for provider in @providers
            if provider.canProvideForBufferPosition(editor, bufferPosition)
                range = provider.getRangeForBufferPosition(editor, bufferPosition)

                interestedProviderInfoList.push({
                    range    : range
                    provider : provider
                })

                # TODO: Expand range to always be that of the widest (or shortest) provider if there are multiple?
                rangeToHighlight = range

        return null if not rangeToHighlight?

        return {
            range : rangeToHighlight

            callback : () =>
                for interestedProviderInfo in interestedProviderInfoList
                    continue if not interestedProviderInfo.range?

                    text = editor.getTextInBufferRange(interestedProviderInfo.range)

                    interestedProviderInfo.provider.handleNavigation(editor, interestedProviderInfo.range, text)
        }
