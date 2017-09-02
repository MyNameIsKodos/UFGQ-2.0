key toucher;

default
{
    touch_start(integer total_number)
    {
        toucher = llDetectedKey(0);
        llRezObject("UFGQ HUD v0.1", llGetPos() + <0,1,0>, <0,0,0>, ZERO_ROTATION, -2048);
    }
    object_rez(key id)
    {
        llSay(-2048, toucher);
    }
}