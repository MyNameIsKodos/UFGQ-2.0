integer mainlight;
integer statlight;
integer powerbtn;

key owner;

integer count;

integer listenhandle;

integer NETWORK_CHANNEL;
key destination;
key checkedID;

integer debug = TRUE; //toggle debug chat output

list authorized = ["d6110a36-8531-4831-a581-3715c8f4a1b2"];

integer ID2Chan(string id)
{
    integer mainkey = 921;
    string tempkey = llGetSubString((string)id, 0, 7);
    integer hex2int = (integer)("0x" + tempkey);
    return hex2int + mainkey;
}

integer contains(string value, string mask) {
    integer tmpy = (llGetSubString(mask,  0,  0) == "%") | 
                  ((llGetSubString(mask, -1, -1) == "%") << 1);
    if(tmpy)
        mask = llDeleteSubString(mask, (tmpy / -2), -(tmpy == 2));
 
    integer tmpx = llSubStringIndex(value, mask);
    if(~tmpx) {
        integer diff = llStringLength(value) - llStringLength(mask);
        return  ((!tmpy && !diff)
             || ((tmpy == 1) && (tmpx == diff))
             || ((tmpy == 2) && !tmpx)
             ||  (tmpy == 3));
    }
    return FALSE;
}

integer authCheck(key ID)
{
    integer authed = 0;
    if(debug) llSay(0, "Checking " + (string)ID + " against the list of authorized UUIDs.");
    for (count = 0;count < llGetListLength(authorized);count++)
    {
        key listedkey = llList2Key(authorized, count);
        if (ID == listedkey) authed = 1;
    }
    return authed;
}


default
{
    state_entry()
    {
        NETWORK_CHANNEL = ID2Chan(llMD5String(llGetObjectDesc(), 0));
        owner = llGetOwner();
        mainlight = 1;
        statlight = 2;
        powerbtn = 3;
        if(debug) llSay(0, "Initializing, please wait...");
        if(debug) llSay(0, "Ready.");
        state offline;
        
    }
}

state offline
{
    state_entry()
    {
        if(debug) llSay(0, "Server Offline");
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
        PRIM_COLOR, mainlight, <0.2,0.5,0.2>, 1.0,
        PRIM_COLOR, statlight, <0.1,0.1,0.1>, 1.0,
        PRIM_GLOW, statlight, 0.0,
        PRIM_FULLBRIGHT, statlight, 0,
        PRIM_COLOR, powerbtn, <0.25,0,0>, 1.0,
        PRIM_GLOW, powerbtn, 0.0,
        PRIM_FULLBRIGHT, powerbtn, 0
        ]);
        llListenRemove(listenhandle);
    }
    touch_end(integer num_detected)
    {
        if(llDetectedKey(0) == owner && llDetectedTouchFace(0) == powerbtn)
        state online;
    }
}

state online
{
    state_entry()
    {
        if(debug) llSay(0, "Server Online");
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
        PRIM_COLOR, mainlight, <0.4,1,0.4>, 1.0,
        PRIM_COLOR, statlight, <0,1,0>, 1,
        PRIM_GLOW, statlight, 0.05,
        PRIM_FULLBRIGHT, statlight, 1,
        PRIM_COLOR, powerbtn, <0,1,0>, 1.0,
        PRIM_GLOW, powerbtn, 0.05,
        PRIM_FULLBRIGHT, powerbtn, 1
        ]);
        listenhandle = llListen(NETWORK_CHANNEL, "", "", "");
    }
    listen(integer chan, string name, key id, string msg)
    {
        if(llList2String(llParseString2List(msg, ["|"], []), 0) == "AUTHREQ")
        {
            destination = llList2Key(llParseString2List(msg, ["|"], []), 1);
            key ID2Check = llList2Key(llParseString2List(msg, ["|"], []), 2);
            if(authCheck(ID2Check))
            {
                if(debug)llSay(0, "Authorized.");
                llRegionSayTo(destination,NETWORK_CHANNEL,"AUTHRES|TRUE");
            }
            else 
            {
                if(debug)llSay(0, llList2String(llParseString2List(msg, ["|"], []), 1) + " is not authorized.");
                llRegionSayTo(destination,NETWORK_CHANNEL,"AUTHRES|FALSE");
            }
        }
    }
    touch_end(integer num_detected)
    {
        integer face = llDetectedTouchFace(0);
        if(llDetectedKey(0) == owner && face == powerbtn)
        state offline;
    }
}