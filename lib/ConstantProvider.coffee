AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides code navigation for global constants.
##
class ConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    hoverEventSelectors: '.constant.other.php'

    ###*
     * @inheritdoc
    ###
    clickEventSelectors: '.constant.other.php'

    ###*
     * @inheritdoc
    ###
    gotoFromWord: (editor, term) ->
        constants = @service.getGlobalConstants()

        return unless constants and term of constants
        return unless constants[term].filename

        atom.workspace.open(constants[term].filename, {
            initialLine    : (constants[term].startLine - 1),
            searchAllPanes : true
        })
