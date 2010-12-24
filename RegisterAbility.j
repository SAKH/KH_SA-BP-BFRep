library RegisterAbility initializer init

globals
    private constant integer HASH_NEXT=53
    private constant integer MAX_HASH_VALUE=8191
    //===================================
    private integer array HashedInt
endglobals

private function Hash takes integer int returns integer
    local integer hash=int-(int/MAX_HASH_VALUE)*MAX_HASH_VALUE
    loop
        exitwhen HashedInt[hash]==int
        if HashedInt[hash]==0 then
            set HashedInt[hash]=int
            return hash
        endif
        set hash=hash+HASH_NEXT
        if hash>=MAX_HASH_VALUE then
            set hash=hash-MAX_HASH_VALUE
        endif
    endloop
    return hash
endfunction

globals
    private trigger array toFire
    private integer this=0
endglobals

private function runFire takes nothing returns boolean
    if IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO)==true then
        set this=Hash(GetSpellAbilityId())
        if toFire[this] != null then
            call TriggerExecute(toFire[this])
            return false
        endif
    endif
    return false
endfunction

private function init takes nothing returns nothing
    local trigger t=CreateTrigger()
    local integer index=0
    call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(t,Condition(function runFire))
endfunction

function RegisterAbility takes integer key, code func returns nothing
    set this=Hash(key)
    set toFire[this]=CreateTrigger()
    call TriggerAddAction(toFire[this],func)
endfunction

endlibrary