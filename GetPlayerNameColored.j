library GetPlayerNameColored initializer initz

globals
    string array GPNC_Name
endglobals


function GetPlayerNameColoredX takes player id returns string
    local playercolor col = GetPlayerColor(id)
    local string r = GetPlayerName(id)
    
    if col == PLAYER_COLOR_RED then
        set r="|cffff0000"+"Forces of the Light Realm"+"|r"
    elseif col == PLAYER_COLOR_BLUE then
        set r="|cff0000ff"+r+"|r"
    elseif col == PLAYER_COLOR_CYAN then
        set r="|cff93ffc9"+r+"|r"
    elseif col == PLAYER_COLOR_PURPLE then
        set r="|cff400080"+r+"|r"
    elseif col == PLAYER_COLOR_YELLOW then
        set r="|cffffff00"+r+"|r"
    elseif col == PLAYER_COLOR_ORANGE then
        set r="|cffff8000"+r+"|r"
    elseif col == PLAYER_COLOR_GREEN then
        set r="|cff00c400"+"Forces of the Darkness Realm"+"|r"
    elseif col == PLAYER_COLOR_PINK then
        set r="|cffff80c0"+r+"|r"
    elseif col == PLAYER_COLOR_LIGHT_GRAY then
        set r="|cff808080"+r+"|r"
    elseif col == PLAYER_COLOR_LIGHT_BLUE then
        set r="|cffc1c1ff"+r+"|r"
    elseif col == PLAYER_COLOR_AQUA then
        set r="|cff5e5e2f"+r+"|r"
    elseif col == PLAYER_COLOR_BROWN then
        set r="|cff004000"+r+"|r"
    else
        set r="|cff000000"+r+"|r"
    endif
    
    return r
endfunction

function GetPlayerNameColored takes player id returns string
    return GPNC_Name[GetPlayerId(id)]
endfunction
// Added this so when heroes are created they can have their name in their players color, the S stands for string, since it returns the
// string, not the actual playercolor constant
function GetPlayerColorS takes player id returns string
    local playercolor col = GetPlayerColor(id)
    local string r = ""
    
    if col == PLAYER_COLOR_RED then
        set r="|cffff0000"
    elseif col == PLAYER_COLOR_BLUE then
        set r="|cff0000ff"
    elseif col == PLAYER_COLOR_CYAN then
        set r="|cff93ffc9"
    elseif col == PLAYER_COLOR_PURPLE then
        set r="|cff400080"
    elseif col == PLAYER_COLOR_YELLOW then
        set r="|cffffff00"
    elseif col == PLAYER_COLOR_ORANGE then
        set r="|cffff8000"
    elseif col == PLAYER_COLOR_GREEN then
        set r="|cff00c400"
    elseif col == PLAYER_COLOR_PINK then
        set r="|cffff80c0"
    elseif col == PLAYER_COLOR_LIGHT_GRAY then
        set r="|cff808080"
    elseif col == PLAYER_COLOR_LIGHT_BLUE then
        set r="|cffc1c1ff"
    elseif col == PLAYER_COLOR_AQUA then
        set r="|cff5e5e2f"
    elseif col == PLAYER_COLOR_BROWN then
        set r="|cff004000"
    else
        set r="|cff000000"
    endif
    
    return r
endfunction

private function initz takes nothing returns nothing
    local integer i=0
    loop
        exitwhen i==11
        set GPNC_Name[i]=GetPlayerNameColoredX(Player(i))
        set i=i+1
    endloop
endfunction

endlibrary