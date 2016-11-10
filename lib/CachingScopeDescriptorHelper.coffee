ScopeDescriptorHelper = require './ScopeDescriptorHelper'

module.exports =

##*
# Caching extension of ScopeDescriptorHelper.
##
class CachingScopeDescriptorHelper extends ScopeDescriptorHelper
    ###*
     * @var {Object}
    ###
    cache: null

    ###*
     * @inherited
    ###
    constructor: (@config) ->
        @cache = {}

    ###*
     * Clears the cache.
    ###
    clearCache: () ->
        @cache = {}

    ###*
     * Internal convenience method that wraps a call to a parent method.
     *
     * @param {String}  cacheKey
     * @param {String}  parentMethodName
     * @param {Array}   parameters
     *
     * @return {Promise|Object}
    ###
    wrapCachedRequestToParent: (cacheKey, parentMethodName, parameters) ->
        if cacheKey of @cache
            return @cache[cacheKey]

        else
            @cache[cacheKey] = CachingScopeDescriptorHelper.__super__[parentMethodName].apply(this, parameters)

            return @cache[cacheKey]

    ###*
     * @inherited
    ###
    getClassListForBufferPosition: (editor, bufferPosition, climbCount = 1) ->
        return @wrapCachedRequestToParent(
            "getClassListForBufferPosition-#{editor.getPath()}-#{bufferPosition.row}-#{bufferPosition.column}-#{climbCount}",
            'getClassListForBufferPosition',
            arguments
        )

     ###*
      * @inherited
     ###
    getClassListFollowingBufferPosition: (editor, bufferPosition, climbCountForPosition) ->
        return @wrapCachedRequestToParent(
            "getClassListFollowingBufferPosition-#{editor.getPath()}-#{bufferPosition.row}-#{bufferPosition.column}-#{climbCountForPosition}",
            'getClassListFollowingBufferPosition',
            arguments
        )

    ###*
     * @inherited
    ###
    getBufferRangeForClassListAtPosition: (editor, classList, bufferPosition, climbCount) ->
        return @wrapCachedRequestToParent(
            "getBufferRangeForClassListAtPosition-#{editor.getPath()}-#{classList.join('_')}-#{bufferPosition.row}-#{bufferPosition.column}-#{climbCount}",
            'getBufferRangeForClassListAtPosition',
            arguments
        )
