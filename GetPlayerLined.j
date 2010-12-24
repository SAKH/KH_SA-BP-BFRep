library GetPlayer initializer int

globals
    private player array playerz
endglobals

function GetPlayer takes integer i returns player
    return playerz[i]
endfunction

private function int takes nothing returns nothing
    local integer i=0
    loop
        set playerz[i]=Player(i)
        set i=i+1
        exitwhen i==14
    endloop
endfunction

endlibrary