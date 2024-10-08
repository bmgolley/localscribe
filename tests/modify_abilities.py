from context import localscribe_enhanced as lse


roster = lse.get_roster()
roster_json = lse.create_json(roster, separateAbilities=True)

add: lse.AbilityChanges = {
    frozenset({frozenset({'Astra Militarum'})}): {
        'Born Soldiers': 'Each time an ASTRA MILITARUM unit from your army Remains Stationary, until the end of the turn, ranged weapons equipped by models in that unit have the [LETHAL HITS] ability.'
    }
}
replace: lse.AbilityChanges = {
    frozenset({frozenset({'Militarum Tempestus Command Squad'})}): {
        'Tempestor Prime': 'While this unit contains a TEMPESTOR PRIME, ranged weapons equipped by models in this unit have the [SUSTAINED HITS 1] ability.'
    }
}
lse.modify_abilities(roster_json, add=add, replace=replace)
pass