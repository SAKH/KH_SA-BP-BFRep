library SP initializer init

globals
    private integer MaxCountPlayers = 0
    public force TeamOne  = CreateForce()
    public force TeamTwo  = CreateForce()
    public force ForceAll = CreateForce()
endglobals

private function Setup takes nothing returns nothing
    local integer i=0
    call ForceAddPlayer(ForceAll,Player(0))
    loop
        exitwhen i==11
        set i=i+1
        if i!=6 then //GetPlayerController(Player(0)) == MAP_CONTROL_USER
            if GetPlayerController(GetPlayer(i)) == MAP_CONTROL_USER then
                if GetPlayerSlotState(GetPlayer(i)) == PLAYER_SLOT_STATE_PLAYING then
                    call SetPlayerAbilityAvailable(GetPlayer(i),'A02Z',false)
                    call ForceAddPlayer(ForceAll,GetPlayer(i))
                    if IsPlayerAlly(GetPlayer(i),GetPlayer(0)) then
                        call ForceAddPlayer(TeamOne,GetPlayer(i))
                    else
                        call ForceAddPlayer(TeamTwo,GetPlayer(i))
                    endif
                    set MaxCountPlayers=MaxCountPlayers+1
                endif
            endif
        endif
    endloop
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function IsPlayerPlaying takes player p returns boolean
    return IsPlayerInForce(p,ForceAll)
endfunction

function IsPlayerPlayingId takes integer id returns boolean
    return IsPlayerInForce(GetPlayer(id),ForceAll)
endfunction

constant function GetMaxPlayerCount takes nothing returns integer
    return MaxCountPlayers
endfunction

private function init takes nothing returns nothing
    local trigger t=CreateTrigger()
    local integer i=0
    call TriggerRegisterTimerEvent(t,0.01,false)
    call TriggerAddAction(t,function Setup)
endfunction

endlibrary