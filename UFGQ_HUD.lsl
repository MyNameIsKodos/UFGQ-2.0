key userID;
integer listenhandle;
integer authhandle;
integer NETWORK_CHANNEL;
integer authed;
integer menuchannel;
string message;


integer ID2Chan(string id)
{
    integer mainkey = 921;
    string tempkey = llGetSubString((string)id, 0, 7);
    integer hex2int = (integer)("0x" + tempkey);
    return hex2int + mainkey;
}


default
{
    state_entry()
    {
        menuchannel = (integer)(llFrand(1000000)+10)*-1;
        listenhandle = llListen(-2048, "", "", "");
        NETWORK_CHANNEL = ID2Chan(llMD5String("UFGQ", 0));
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        userID = msg;
        llListenRemove(listenhandle);
        llRequestPermissions( userID, PERMISSION_ATTACH );
    }
 
    run_time_permissions( integer vBitPermissions )
    {
        if( vBitPermissions & PERMISSION_ATTACH )
        {
            llAttachToAvatarTemp( ATTACH_HUD_BOTTOM_LEFT );
            state isAvailable;
        }
        else
        {
            llOwnerSay( "Permission to attach denied" );
            llDie();
        }
    }

 
    on_rez(integer rez)
    {
        if(!llGetAttached())
        { //reset the script if it's not attached.
            llResetScript();
        }
    }
}

state isAvailable
{
    state_entry()
    {
        authhandle = llListen(NETWORK_CHANNEL, "", "", "");
    }
    touch_end(integer num)
    {
        llRegionSay(NETWORK_CHANNEL, "AUTHREQ|" + (string)llGetKey() + "|" + (string)llDetectedKey(0));
        llSleep(3);
        if(authed == 1)
        {
            llDialog(llDetectedKey(0), "Test Dialog", ["OK"], menuchannel);
        }
        else if(authed == 0)
        {
            llOwnerSay("Came back not authed.");
            llOwnerSay((string)authed);
            llOwnerSay(message);
        }
    }
    listen(integer chan, string name, key id, string msg)
    {
        if(llList2String(llParseString2List(msg, ["|"],[]), 0) == "AUTHRES")
        {
            authed = llList2Integer(llParseString2List(msg, ["|"],[]), 2);
            llListenRemove(authhandle);
            llSay(0, "Auth Result: " + (string)authed);
            message = msg;
        }
        else if (chan == menuchannel)
        {
            llSay(0, msg);
        }
    }
}