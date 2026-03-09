local totest = {
    -- Metatable & Environment Manipulation
    getrawmetatable = getrawmetatable,
    setrawmetatable = setrawmetatable,
    setreadonly = setreadonly,
    isreadonly = isreadonly,
    hookmetamethod = hookmetamethod,
    getgenv = getgenv,
    getrenv = getrenv,
    getsenv = getsenv,
    getreg = getreg,
    getgc = getgc,
    getinstances = getinstances,
    getnilinstances = getnilinstances,

    -- Signals & Instance Interaction
    firesignal = firesignal,
    getconnections = getconnections,
    fireclickdetector = fireclickdetector,
    firetouchinterest = firetouchinterest,
    fireproximityprompt = fireproximityprompt,
    gethui = gethui,

    -- Script, Closure & Function Manipulation
    checkcaller = checkcaller,
    islclosure = islclosure,
    iscclosure = iscclosure,
    isexecutorclosure = isexecutorclosure,
    checkclosure = checkclosure,
    clonefunction = clonefunction,
    newcclosure = newcclosure,
    hookfunction = hookfunction,
    replaceclosure = replaceclosure,
    getscriptbytecode = getscriptbytecode,
    getscriptclosure = getscriptclosure,
    getscripthash = getscripthash,
    getcallingscript = getcallingscript,

    -- Filesystem API
    readfile = readfile,
    writefile = writefile,
    appendfile = appendfile,
    loadfile = loadfile,
    listfiles = listfiles,
    isfile = isfile,
    isfolder = isfolder,
    makefolder = makefolder,
    delfolder = delfolder,
    delfile = delfile,

    -- Network & Web
    request = request or http_request or (fluxus and fluxus.request),

    -- Identity & Execution
    identifyexecutor = identifyexecutor,
    getthreadidentity = getthreadidentity or getidentity or getthreadcontext,
    setthreadidentity = setthreadidentity or setidentity or setthreadcontext,
    setclipboard = setclipboard,
    getcustomasset = getcustomasset,
    queue_on_teleport = queue_on_teleport,
    clear_teleport_queue = clear_teleport_queue,
    setfpscap = setfpscap,

    -- Input & Mouse/Keyboard Simulation
    mouse1click = mouse1click,
    mouse1press = mouse1press,
    mouse1release = mouse1release,
    mouse2click = mouse2click,
    mouse2press = mouse2press,
    mouse2release = mouse2release,
    mousemoverel = mousemoverel,
    mousemoveabs = mousemoveabs,
    keypress = keypress,
    keyrelease = keyrelease,

    -- Cache & Drawing
    cleardrawcache = cleardrawcache,
    getrenderproperty = getrenderproperty,
    setrenderproperty = setrenderproperty,

    -- Debug Library (Extended for Exploits)
    ["debug.getconstant"] = debug and debug.getconstant,["debug.setconstant"] = debug and debug.setconstant,
    ["debug.getconstants"] = debug and debug.getconstants,
    ["debug.getinfo"] = debug and debug.getinfo,
    ["debug.getproto"] = debug and debug.getproto,
    ["debug.setproto"] = debug and debug.setproto,
    ["debug.getprotos"] = debug and debug.getprotos,
    ["debug.getstack"] = debug and debug.getstack,
    ["debug.setstack"] = debug and debug.setstack,
    ["debug.getupvalue"] = debug and debug.getupvalue,["debug.setupvalue"] = debug and debug.setupvalue,
    ["debug.getupvalues"] = debug and debug.getupvalues,
    ["debug.setmetatable"] = debug and debug.setmetatable,

    -- Cryptography & Compression
    ["crypt.hash"] = crypt and crypt.hash,["crypt.encrypt"] = crypt and crypt.encrypt,
    ["crypt.decrypt"] = crypt and crypt.decrypt,
    ["crypt.base64encode"] = (crypt and crypt.base64encode) or base64encode,
    ["crypt.base64decode"] = (crypt and crypt.base64decode) or base64decode,
    lz4compress = lz4compress,
    lz4decompress = lz4decompress
}

for funcName, func in pairs(totest) do
    if type(func) == "function" then
        print(funcName .. " is supported!")
    else
        print(funcName .. " is NOT supported (returns nil).")
    end
end
