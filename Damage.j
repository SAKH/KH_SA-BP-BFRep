//  
//      ___   _     __  __   _   ___  ____    _______________________________
//     |   \ /_\   /  |/  | /_\ /  _\|  __|   ||      D E A L   I T ,      ||
//     | |) / _ \ / / | / |/ _ \| |/||  __|   ||    D E T E C T   I T ,    ||
//     |___/_/ \_/_/|__/|_|_/ \_\___/|____|   ||     B L O C K   I T .     ||
//                            By Jesus4Lyf    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//                                                                    v 1.0.4
//      What is Damage?
//     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//          Damage is a damage dealing, detection and blocking system. It implements
//          all such functionality. It also provides a means to detect what type
//          of damage was dealt, so long as all damage in your map is dealt using
//          this system's deal damage functions (except for basic attacks).
//
//          It is completely recursively defined, meaning if you deal damage on
//          taking damage, the type detection and other features like blocking
//          will not malfunction.
//          
//      How to implement?
//     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//          Create a new trigger object called Damage, go to 'Edit -> Convert to
//          Custom Text', and replace everything that's there with this script.
//
//          At the top of the script, there is a '//! external ObjectMerger' line.
//          Save your map, close your map, reopen your map, and then comment out this
//          line. Damage is now implemented. This line creates a dummy ability used
//          in the system in some circumstances with damage blocking.
//
//      Functions:
//     ¯¯¯¯¯¯¯¯¯¯¯¯
//          function Damage_RegisterEvent takes trigger whichTrigger returns nothing
//              - This registers a special "any unit takes damage" event.
//              - This event supports dynamic trigger use.
//              - Only triggers registered on this event may block damage.
//
//          function Damage_GetType takes nothing returns damagetype
//              - This will get the type of damage dealt, like an event response,
//                for when using a unit takes damage event (or the special event above).
//
//          function Damage_IsPhysical takes nothing returns boolean
//          function Damage_IsSpell takes nothing returns boolean
//          function Damage_IsPure takes nothing returns boolean
//              - Wrappers to simply check if Damage_GetType is certain types.
//
//          function Damage_IsAttack takes nothing returns boolean
//              - Checks if the damage is from a physical attack (so you can deal
//                physical damage without it being registered as an actual attack).
//
//          function Damage_Block takes real amount returns nothing
//          function Damage_BlockAll takes nothing returns nothing
//              - For use only with Damage_RegisterEvent.
//              - Blocks 'amount' of the damage dealt.
//              - Multiple blocks at once work correctly.
//              - Blocking more than 100% of the damage will block 100% instead.
//              - Damage_BlockAll blocks 100% of the damage being dealt.
//
//          function Damage_EnableEvent takes boolean enable returns nothing
//              - For disabling and re-enabling the special event.
//              - Use it to deal damage which you do not want to be detected by
//                the special event.
//
//          function UnitDamageTargetEx takes lots of things returns boolean
//              - Replaces UnitDamageTarget in your map, with the same arguments.
//
//          function Damage_Physical takes unit source, unit target, real amount,
//            attacktype whichType, boolean attack, boolean ranged returns boolean
//              - A clean wrapper for physical damage.
//              - 'attack' determines if this is to be treated as a real physical
//                attack or just physical type damage.
//              - 'ranged' determines if this is to be treated as a ranged or melee
//                attack.
//
//          function Damage_Spell takes unit source, unit target, real amount returns boolean
//              - A clean wrapper for spell damage.
//
//          function Damage_Pure takes unit source, unit target, real amount returns boolean
//              - A clean wrapper for pure type damage (universal type, 100% damage).
//          
//      Thanks:
//     ¯¯¯¯¯¯¯¯¯
//          - Romek, for helping me find a better way to think about damage blocking.
//
library Damage uses AIDS, Event
    //============================================================
    //! external ObjectMerger w3a AIlz dprv anam "Life Bonus" ansf "(Damage System)" Ilif 1 500000 aite 0
    globals
        private constant integer LIFE_BONUS_ABIL='dprv'
    endglobals
    
    //============================================================
    globals
        private Event OnDamageEvent
        private boolean EventEnabled=true
    endglobals
    
    public function RegisterEvent takes trigger whichTrigger returns trigger
        call OnDamageEvent.register(whichTrigger)
    return whichTrigger
    endfunction
    
    public function EnableEvent takes boolean enable returns nothing
        set EventEnabled=enable
    endfunction
    
    //============================================================
    globals
        private integer TypeStackLevel=0
        private damagetype array TypeStackValue
        private boolean array TypeStackAttack
        private real array ToBlock
    endglobals
    
    public function GetType takes nothing returns damagetype
        return TypeStackValue[TypeStackLevel]
    endfunction
    
    public function IsAttack takes nothing returns boolean
        return TypeStackAttack[TypeStackLevel]
    endfunction
    
    public function Block takes real amount returns nothing
        set ToBlock[TypeStackLevel]=ToBlock[TypeStackLevel]+amount
    endfunction
    
    public function BlockAll takes nothing returns nothing
        set ToBlock[TypeStackLevel]=ToBlock[TypeStackLevel]+GetEventDamage()
    endfunction
    
    //============================================================
    globals
        private integer BlockNum=0
        private unit array BlockUnit
        private real array BlockUnitLife
        private real array BlockRedamage
        private unit array BlockDamageSource
        
        private timer BlockTimer=CreateTimer()
    endglobals
    
    //============================================================
    globals
        private unit array RemoveBoosted
        private integer RemoveBoostedMax=0
        
        private timer RemoveBoostedTimer=CreateTimer()
    endglobals
    
    globals//locals
        private real BoostedLifeTemp
        private unit BoostedLifeUnit
    endglobals
    private function RemoveBoostedTimerFunc takes nothing returns nothing
        loop
            exitwhen RemoveBoostedMax==0
            set BoostedLifeUnit=RemoveBoosted[RemoveBoostedMax]
            set BoostedLifeTemp=GetWidgetLife(BoostedLifeUnit)
            call UnitRemoveAbility(BoostedLifeUnit,LIFE_BONUS_ABIL)
            if BoostedLifeTemp>0.405 then
                call SetWidgetLife(BoostedLifeUnit,BoostedLifeTemp)
            endif
            set RemoveBoostedMax=RemoveBoostedMax-1
        endloop
    endfunction
    
    //============================================================
    private keyword Detector // Darn, I actually had to do this. XD
    globals//locals
        private unit ForUnit
        private real NextHealth
    endglobals
    private function OnDamageActions takes nothing returns boolean
        if EventEnabled and GetEventDamage()!=0. then
            call OnDamageEvent.fire()
            
            if ToBlock[TypeStackLevel]!=0. then
                //====================================================
                // Blocking
                set ForUnit=GetTriggerUnit()
                
                set NextHealth=GetEventDamage()
                if ToBlock[TypeStackLevel]>=NextHealth then
                    set NextHealth=GetWidgetLife(ForUnit)+NextHealth
                else
                    set NextHealth=GetWidgetLife(ForUnit)+ToBlock[TypeStackLevel]
                endif
                
                call SetWidgetLife(ForUnit,NextHealth)
                if GetWidgetLife(ForUnit)<NextHealth then
                    // NextHealth is over max health.
                    call UnitAddAbility(ForUnit,LIFE_BONUS_ABIL)
                    call SetWidgetLife(ForUnit,NextHealth)
                    
                    set RemoveBoostedMax=RemoveBoostedMax+1
                    set RemoveBoosted[RemoveBoostedMax]=ForUnit
                    call ResumeTimer(RemoveBoostedTimer)
                endif
                //====================================================
                set ToBlock[TypeStackLevel]=0.
            endif
        endif
        return false
    endfunction
    
    //============================================================
    function UnitDamageTargetEx takes unit whichUnit, widget target, real amount, boolean attack, boolean ranged, attacktype attackType, damagetype damageType, weapontype weaponType returns boolean
        local boolean result
        set TypeStackLevel=TypeStackLevel+1
        set TypeStackValue[TypeStackLevel]=damageType
        set TypeStackAttack[TypeStackLevel]=attack
        set result=UnitDamageTarget(whichUnit,target,amount,attack,ranged,attackType,damageType,weaponType)
        set TypeStackLevel=TypeStackLevel-1
        return result
    endfunction
    //! textmacro Damage__DealTypeFunc takes NAME, TYPE
        public function $NAME$ takes unit source, unit target, real amount returns boolean
            return UnitDamageTargetEx(source,target,amount,false,false,ATTACK_TYPE_NORMAL,$TYPE$,WEAPON_TYPE_WHOKNOWS)
        endfunction
        public function Is$NAME$ takes nothing returns boolean
            return GetType()==$TYPE$
        endfunction
    //! endtextmacro
    
    //! runtextmacro Damage__DealTypeFunc("Pure","DAMAGE_TYPE_UNIVERSAL")
    //! runtextmacro Damage__DealTypeFunc("Spell","DAMAGE_TYPE_MAGIC")
    
    // Uses different stuff, but works much the same way.
    public function Physical takes unit source, unit target, real amount, attacktype whichType, boolean attack, boolean ranged returns boolean
        return UnitDamageTargetEx(source,target,amount,attack,ranged,whichType,DAMAGE_TYPE_NORMAL,WEAPON_TYPE_WHOKNOWS)
    endfunction
    public function IsPhysical takes nothing returns boolean
        return GetType()==DAMAGE_TYPE_NORMAL
    endfunction
    
    //============================================================
    private struct Detector extends array // Uses AIDS.
        //! runtextmacro AIDS()
        
        private static conditionfunc ACTIONS_COND
        
        private trigger t
        
        private method AIDS_onCreate takes nothing returns nothing
            set this.t=CreateTrigger()
            call TriggerAddCondition(this.t,thistype.ACTIONS_COND)
            call TriggerRegisterUnitEvent(this.t,this.unit,EVENT_UNIT_DAMAGED)
        endmethod
        
        private method AIDS_onDestroy takes nothing returns nothing
            call DestroyTrigger(this.t)
        endmethod
        
        private static method AIDS_onInit takes nothing returns nothing
            set thistype.ACTIONS_COND=Condition(function OnDamageActions)
        endmethod
    endstruct
    
    //============================================================
    private module InitModule
        private static method onInit takes nothing returns nothing
            local unit abilpreload=CreateUnit(Player(15),'uloc',0,0,0)
            call UnitAddAbility(abilpreload,LIFE_BONUS_ABIL)
            call RemoveUnit(abilpreload)
            set abilpreload=null
            
            set OnDamageEvent=Event.create()
            set TypeStackValue[TypeStackLevel]=DAMAGE_TYPE_NORMAL
            set TypeStackAttack[TypeStackLevel]=true
            call TimerStart(RemoveBoostedTimer,0.0,false,function RemoveBoostedTimerFunc)
        endmethod
    endmodule
    private struct InitStruct extends array
        implement InitModule
    endstruct
endlibrary