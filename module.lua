maps = {"0","1","2","3","4","5","6","8","9","10",
"11","12","13","14","15","16","17","18","19","20",
"21","22","23","24","25","26","27","28","30","31",
"32","33","34","35","36","37","38","39","40","41",
"42","43","44","45","46","47","48","49","50","51",
"52","53","54","55","56","57","58","59","60","61",
"62","63","64","65","66","67","68","69","70","71",
"72","73","74","75","76","77","78","79","80","81",
"82","83","84","85","86","87","88","89","90","91",
"92","93","94","95","96","97","98","99","100","101",
"102","103","104","105","106","107","109","114","115",
"116","117","118","119","120","121","122","123","124",
"125","126","127","128","129","130","131","132","133",
"134","136","137","138","139","140","141","142","143",
"144","145","146","147","148","149","150","151","152",
"153","154","155","156","157","158","159","160","161",
"162","163","164","165","166","167","168","170","171",
"172","173","174","175","176","177","178","179","180",
"181","182","183","184","185","186","187","188","189",
"190","191","192","200","201","202","203","204","205",
"206","207","208","209","210","211","212","213","214",
"215","216","217","218","219","220","221","222","223",
"224","225","226","227"}

modifiers = {
    miniMice = {
        name = "Mini Mice",
        description = "All mice in the room are very small!",
        incompatibilities = { 'hugeMice' }
    },
    hugeMice = {
        name = "Huge Mice",
        description = "All mice in the room are very big!",
        incompatibilities = { 'miniMice' }
    },
    --[[
    randomGhostObjects = {
        name = "Random ghost objects",
        description = "Every object summoned by the shaman will be randomly ghosted or not.",
    },
    ]]
    everyoneIsShaman = {
        name = "Everyone is shaman",
        description = "Everyone is shaman!",
    },
    discoMode = {
        name = "Disco Mode",
        description = "Makes player names and map background change colors.",
    },
    newYear = {
        name = "Is this the new year?",
        description = "Creates explosions in random places.",
    },
    mouseTrain = {
        name = "Mouse Train",
        description = "All mice are linked together in random order.",
    },
    meep = {
        name = "Meep!",
        description = "Gives everyone meep.",
        incompatibilities = { 'miceCanFly' }
    },
    transformations = {
        name = "Transformations",
        description = "Gives everyone the power of transformation.",
    },
    cantStopSitting = {
        name = "Can't stop sitting",
        description = "Makes everyone sit all the time.",
        incompatibilities = { 'squatBeforeYouDie' }
    },
    conjurationRain = {
        name = "It's raining conjuration",
        description = "Randomly spawns conjuration in random places (the gray squares that shammies can sometimes draw with)",
    },
    mapFlip = {
        name = "Map flip",
        description = "The map is flipped.",
    },
    skilllessDivine = {
        name = "Skillless Divine",
        description = "Sets the shaman(s) mode to divine without skills."
    },
    areWeInSpace = {
        name = "Are we in space?",
        description = "Sets the gravity very low."
    },
    theresAVampireAmongUs = {
        name = "There's a vampire among us",
        description = "A random player becomes a vampire. Vampirism heals after 10 seconds."
    },
    fallDamage = {
        name = "Fall damage",
        description = "Mice die when they hit a ground too hard."
    },
    snowfall = {
        name = "Snowfall",
        description = "It's snowing! (snowballs are buffed too!)"
    },
    miceCanFly = {
        name = "Mice can fly?",
        description = "You can fly by pressing Space!",
        incompatibilities = { 'meep' }
    },
    itsColdOutHere = {
        name = "It's cold out here",
        description = "Mice can freeze for around a second occasionally."
    },
    anotherLife = {
        name = "Another life",
        description = "You get to respawn once after you die.",
        playerRoundData = {
            alreadyRespawned = false
        }
    },
    squatBeforeYouDie = {
        name = "Squat before you die!",
        description = "You die if you don't squat at least once every 5 seconds.",
        incompatibilities = { 'cantStopSitting' },
        playerRoundData = {
            lastSquatted = -1
        }
    },
    mouseArchery = {
        name = "Mouse archery",
        description = "You can shoot arrows every 5 seconds by pressing Q!",
        playerRoundData = {
            lastShotArrow = -1
        }
    },
    indecisiveWind = {
        name = "Indecisive Wind",
        description = "There's wind that can't decide whether it goes right or left."
    },
    death = {
        name = "Death",
        description = "Every second a death bonus spawns at a random position."
    },
    shyShamanObjects = {
        name = "Shy shaman objects",
        description = "There's a 50% chance that a shaman object won't actually spawn."
    },
    ateItOnTheWayBack = {
        name = "Ate it on the way back",
        description = "Cheese you picked up can randomly disappear."
    },
    microsleeps = {
        name = "Microsleeps",
        description = "There's a chance your screen will turn black for split second." 
    }
}
playerRoundData = {}

eventLoopTicks = 0
eventLoopTicksRound = 0

scheduledFunctionCalls = {}

function doLater(callback, ticksLater, forgetAfterNewRound)
    scheduledFunctionCalls[#scheduledFunctionCalls + 1] = {
        func = callback,
        tick = eventLoopTicks + ticksLater,
        forgetAfterNewRound = forgetAfterNewRound
    }
end

modifierNames = {}
for modifierName, _ in pairs(modifiers) do
    modifierNames[#modifierNames + 1] = modifierName
end

math.randomseed(os.time())

activeModifiers = {}

forcedGravity = nil
forcedWind = nil

table.shuffle = function(table)
    for i = #table, 2, -1 do
        local j = math.random(i)
        table[i], table[j] = table[j], table[i]
    end
    return table
end

table.copy = function(table, deep)
    deep = deep or false
    local newTable = {}
    for i, element in pairs(table) do
        if type(element) == 'table' then
            if deep then
                newTable[i] = table.copy(element, deep)
            end
        else
            newTable[i] = element
        end
    end
    return newTable
end

function resetPlayerRoundData(playerName)
    playerRoundData[playerName] = {}
    for modifier, modifierData in pairs(modifiers) do
        if modifierData.playerRoundData then
            playerRoundData[playerName][modifier] = table.copy(modifierData.playerRoundData)
        end
    end
end

function initPlayer(playerName)
    ui.addPopup(1, 0, "<p align='center'><font size='16'>Welcome to <b>Wacknilla</b>!</font></p>\nThis module is almost like normal vanilla.\nThe difference is that every round will have random modifiers added to it.", playerName, 250, 150, 300, true)
    ui.addTextArea(1, 'Active modifiers', playerName, 625, 25, 165, 25, 0x101010, 0, 0.5, true)
    updateActiveModifiersList(playerName)
    system.bindKeyboard(playerName, 32, true, true) -- Space
    system.bindKeyboard(playerName, 3, true, true) -- S + Down arrow
    system.bindKeyboard(playerName, 81, true, true) -- Q
    resetPlayerRoundData(playerName)
end

function eventNewPlayer(playerName)
	initPlayer(playerName)
    if getMiceAlive() < 3 then
        startNewRound()
    end
end

function eventPlayerDied(playerName)
    if isModifierActive('anotherLife') and not playerRoundData[playerName].anotherLife.alreadyRespawned then
        tfm.exec.respawnPlayer(playerName)
        playerRoundData[playerName].anotherLife.alreadyRespawned = true
        return
    end
    tfm.exec.setPlayerScore(playerName, 1, true)
    if getMiceAlive() == 0 then
        startNewRound()
    end
end

function clearMice()
    for player, playerData in pairs(tfm.get.room.playerList) do
        resetPlayerRoundData(player)
        tfm.exec.giveTransformations(player, false)
        for player2, playerData2 in pairs(tfm.get.room.playerList) do
            if player ~= player2 then
                tfm.exec.linkMice(player, player2, false)
            end
        end
    end
end

function updateActiveModifiersList(playerName) 
    ui.updateTextArea(1, string.format('<a href="event:activeModifiers"><p align="center"><font color="#FF8547" size="14"><b>Active modifiers (%d)</b></font></p>', #activeModifiers), playerName)
end

function eventLoop(currentTime, timeRemaining)
    for i, scheduledFunctionCall in ipairs(scheduledFunctionCalls) do
        if eventLoopTicks >= scheduledFunctionCall.tick then
            scheduledFunctionCall.func()
            table.remove(scheduledFunctionCalls, i)
        end
    end

    eventLoopTicks = eventLoopTicks + 1
    eventLoopTicksRound = eventLoopTicksRound + 1

    if timeRemaining <= 0 then
        startNewRound()
    else
        if isModifierActive('discoMode') then
            local color = math.random(0, 0xFFFFFF)
            for playerName, playerData in pairs(tfm.get.room.playerList) do
                tfm.exec.setNameColor(playerName, color)
            end
            ui.setBackgroundColor(string.format("#%06X", color))
        end
        if isModifierActive('newYear') and math.random(1, 2) == 1 then
            local x, y = math.random(0, 800), math.random(0, 400)
            tfm.exec.explosion(x, y, 10, 80, false)
            tfm.exec.displayParticle(10, x, y, 0, 0, 0, 0, nil)
        end

        if isModifierActive('conjurationRain') and math.random(1, 2) == 1 then
            local x, y = math.random(0, 80), math.random(0, 40)
            tfm.exec.addConjuration(x, y, 8000)
        end
        
        if isModifierActive('cantStopSitting') then
            for playerName, playerData in pairs(tfm.get.room.playerList) do
                tfm.exec.playEmote(playerName, 8)
            end
        end

        if isModifierActive('squatBeforeYouDie') then
            for playerName, playerData in pairs(tfm.get.room.playerList) do
                if playerRoundData[playerName].squatBeforeYouDie.lastSquatted == -1 then
                    playerRoundData[playerName].squatBeforeYouDie.lastSquatted = os.time()
                elseif playerRoundData[playerName].squatBeforeYouDie.lastSquatted + 5000 <= os.time() then
                    tfm.exec.killPlayer(playerName)
                end
            end
        end

        if eventLoopTicks % 2 == 0 and isModifierActive('indecisiveWind') then
            if math.random(1, 2) == 1 then
                forcedWind = 4.0
            else
                forcedWind = -4.0
            end
            tfm.exec.setWorldGravity(forcedWind, forcedGravity)
        end

        if eventLoopTicks % 2 == 0 and isModifierActive('death') then
            tfm.exec.addBonus(2, math.random(0, 800), math.random(0, 400), 0, 0, true, nil)
        end

        if eventLoopTicks % 10 == 0 and isModifierActive('ateItOnTheWayBack') then
            if math.random(1, 3) == 1 then
                local playersWithCheese = {}
                for player, playerData in pairs(tfm.get.room.playerList) do
                    if playerData.hasCheese then
                        playersWithCheese[#playersWithCheese + 1] = player
                    end
                end
                if #playersWithCheese > 0 then
                    tfm.exec.removeCheese(playersWithCheese[math.random(1, #playersWithCheese)])
                end
            end
        end

        if eventLoopTicks % 6 == 0 and isModifierActive('microsleeps') then
            if math.random(1, 3) == 1 then
                tfm.exec.addPhysicObject(1, 400, 200, {
                    type = 12, 
                    width = 800, 
                    height = 400, 
                    groundCollision = false,
                    miceCollision = false,
                    color = 0x000000,
                    dynamic = false,
                    foreground = true
                })
                doLater(function()
                    tfm.exec.removePhysicObject(1)
                end, 1, true)
            end
        end
    end
end

function eventPlayerRespawn(playerName)
    if isModifierActive('squatBeforeYouDie') then
        playerRoundData[playerName].squatBeforeYouDie.lastSquatted = os.time()
    end
end

function eventSummoningEnd(playerName, objectType, xPosition, yPosition, angle, xSpeed, ySpeed, objectData)
    --[[
    if isModifierActive('randomGhostObjects') then
        tfm.exec.removeObject(objectData.id)
        tfm.exec.addShamanObject(objectData.type, objectData.x, objectData.y, objectData.angle, objectData.vx, objectData.vy, (math.random(1, 2) == 1))
    end]]
    if objectData.id >= 11000 and isModifierActive('shyShamanObjects') then
        if math.random(1, 2) == 1 then
            tfm.exec.removeObject(objectData.id)
        end
    end
end

function isModifierActive(modifierName)
    for i, modifier in ipairs(activeModifiers) do
        if modifier == modifierName then
            return true
        end
    end
    return false
end

function eventNewGame()
    local playerNames = {}
    for player, playerData in pairs(tfm.get.room.playerList) do
        if isModifierActive('miniMice') then
            tfm.exec.changePlayerSize(player, 0.4)
        elseif isModifierActive('hugeMice') then
            tfm.exec.changePlayerSize(player, 2)
        else
            tfm.exec.changePlayerSize(player, 1.0)
        end

        if isModifierActive('everyoneIsShaman') then
            tfm.exec.setShaman(player, true)
            ui.setShamanName('Everyone!')
        elseif isModifierActive('transformations') then
            tfm.exec.giveTransformations(player, true)
        end

        if isModifierActive('skilllessDivine') then
            tfm.exec.setShamanMode(player, 2)
        else 
            tfm.exec.setShamanMode(player, nil)
        end

        if isModifierActive('meep') then
            tfm.exec.giveMeep(player, true)
        end

        updateActiveModifiersList(playerName)
        playerNames[#playerNames + 1] = player
    end

    if isModifierActive('mouseTrain') then
        table.shuffle(playerNames)
        for i = 1, #playerNames - 1 do
            --leaderPlayerData = tfm.get.room.  playerList[playerNames[#playerNames]]
            --tfm.exec.movePlayer(playerNames[i], leaderPlayerData.x, leaderPlayerData.y, false, 0, 0, true)
            tfm.exec.linkMice(playerNames[i], playerNames[i + 1], true)
        end
    end

    if isModifierActive('theresAVampireAmongUs') then
        doLater(function()
            tfm.exec.setVampirePlayer(playerNames[math.random(1, #playerNames)], true)
        end, 10, true)
    end

    if isModifierActive('fallDamage') then
        tfm.exec.setAieMode(true, 5, nil)
    end

    if isModifierActive('areWeInSpace') then
        forcedGravity = 2.5
    end

    if isModifierActive('indecisiveWind') then
        if math.random(1, 2) == 1 then
            forcedWind = 4.0
        else
            forcedWind = -4.0
        end
    end

    if forcedWind ~= nil or forcedGravity ~= nil then
        tfm.exec.setWorldGravity(forcedWind, forcedGravity)
    end

    if isModifierActive('snowfall') then
        tfm.exec.snow(120, 100)
    else
        tfm.exec.snow(0, 0)
    end

    if isModifierActive('itsColdOutHere') then
        itsColdOutHereLoopFunc = function()
            doLater(function()
                itsColdOutHereLoopFunc()
                local freeze = math.random(1, 2) == 1
                if freeze then
                    local playerNames = {}
                    for player, playerData in pairs(tfm.get.room.playerList) do
                        playerNames[#playerNames + 1] = player
                    end
                    local chosenPlayer = playerNames[math.random(1, #playerNames)]
                    tfm.exec.freezePlayer(chosenPlayer, true)
                    doLater(function()
                        tfm.exec.freezePlayer(chosenPlayer, false)
                    end, 2, true)
                end
            end, 10, true)
        end
        doLater(itsColdOutHereLoopFunc, 10, true)
    end

    if isModifierActive('squatBeforeYouDie') then 
        ui.addTextArea(4, "<p align='center' size='24'><font color='#000000'><b>Squat before you die!</b></font></p>", nil, 200, 375, 400, 25, nil, nil, 0.0, true)
        doLater(function()
            ui.removeTextArea(4, nil)
        end, 8, 2)
    end
end

function canAddModifier(modifierName)
    for i, modifier in ipairs(activeModifiers) do
        if modifier == modifierName then
            return false
        end
        if modifiers[modifier].incompatibilities then
            for j, incompatibility in ipairs(modifiers[modifier].incompatibilities) do
                if incompatibility == modifierName then
                    return false
                end
            end
        end
    end
    return true
end

function startNewRound(forcedModifiers)
    if not firstNewRoundCalled then
        firstNewRoundCalled = true
    elseif eventLoopTicksRound < 7 then
        doLater(function()
            startNewRound(forcedModifiers)
        end, eventLoopTicksRound - 7, true)
        return
    end

    for i, scheduledFunctionCall in ipairs(scheduledFunctionCalls) do
        if scheduledFunctionCall.forgetAfterNewRound then
            if scheduledFunctionCall.forgetAfterNewRound == 2 then
                scheduledFunctionCall.func()
            end
            table.remove(scheduledFunctionCalls, i)
        end
    end

    activeModifiers = {}

    if forcedModifiers then
        for i, forcedModifier in pairs(forcedModifiers) do
            activeModifiers[#activeModifiers + 1] = forcedModifier
        end
    end

    local iterations = math.random(1, math.min(3, #modifierNames))

    for i = 1, iterations do
        local pickedModifier = modifierNames[math.random(1, #modifierNames)]
        if canAddModifier(pickedModifier) then
            activeModifiers[#activeModifiers + 1] = pickedModifier
        end
    end
    forcedGravity = nil
    forcedWind = nil
    eventLoopTicksRound = 0
    clearMice()
    tfm.exec.disableAllShamanSkills(isModifierActive('skilllessDivine'))
    tfm.exec.setGameTime(2, true)
    tfm.exec.newGame(maps[math.random(0, #maps)], isModifierActive('mapFlip'))
end

function eventPlayerWon(playerName, timeElapsed, timeElapsedSinceRespawn)
    if getMiceAlive() == 0 then
        startNewRound()
    end
end

function eventKeyboard(playerName, keyCode, down, xPlayerPosition, yPlayerPosition)
    if keyCode == 32 then -- Space
        if isModifierActive('miceCanFly') then
            tfm.exec.movePlayer(playerName, 0, 0, true, 0, -60.0, false)
            tfm.exec.displayParticle(3, xPlayerPosition, yPlayerPosition, 0, 0.4, 0, 0, nil)
        end
    elseif keyCode == 3 then -- S + Down arrow
        if isModifierActive('squatBeforeYouDie') then
            playerRoundData[playerName].squatBeforeYouDie.lastSquatted = os.time()
        end
    elseif keyCode == 81 then -- Q
        if isModifierActive('mouseArchery') and playerRoundData[playerName].mouseArchery.lastShotArrow + 5000 <= os.time() then
            if tfm.get.room.playerList[playerName].isFacingRight then
                tfm.exec.addShamanObject(35, xPlayerPosition + 20, yPlayerPosition, 0, 50, 0, false)
            else
                tfm.exec.addShamanObject(35, xPlayerPosition - 20, yPlayerPosition, 180, -50, 0, false)
            end
            playerRoundData[playerName].mouseArchery.lastShotArrow = os.time()
        end
    end
end

function getMiceAlive()
    local playersAlive = 0
    for player, playerData in pairs(tfm.get.room.playerList) do
        if not playerData.isDead then
            playersAlive = playersAlive + 1
        end
    end
    return playersAlive
end

function openActiveModifiersWindow(playerName)
    local textAreaText = '<p align="center"><font size="18" color="#BABD2F"><b>Active modifiers</b></font></p>'

    for i, modifier in ipairs(activeModifiers) do
        textAreaText = textAreaText .. string.format('<p><font size="14" color="#98E2EB">%s</font><br><font size="8" color="#AAAAAA">%s</p><br>', modifiers[modifier].name, modifiers[modifier].description)
    end

    ui.addTextArea(2, textAreaText, playerName, 150, 50, 500, 325, 0x101010, 0, 0.95, true)
    ui.addTextArea(3, '<a href="event:closeActiveModifiersWindow"><p align="center"><font size="11" color="#000000"><b>X</b></font></p></a>', playerName, 625, 60, 15, 15, 0xFF0000, 0, 1.0, true)
end

function closeActiveModifiersWindow(playerName)
    ui.removeTextArea(2, playerName)
    ui.removeTextArea(3, playerName)
end

function eventTextAreaCallback(textAreaID, playerName, callback)
    if callback == "activeModifiers" then
        openActiveModifiersWindow(playerName)
    elseif callback == "closeActiveModifiersWindow" then
        closeActiveModifiersWindow(playerName)
    end
end

function eventChatCommand(playerName, message)
    local args = {}
    for arg in message:gmatch("%S+") do
        args[#args + 1] = arg
    end
    local command = table.remove(args, 1)

    -- for debugging purposes
    if command == "nr" then
        local forcedModifiers = {}
        for i, arg in ipairs(args) do
            if modifiers[arg] then
                forcedModifiers[#forcedModifiers + 1] = arg
            end
        end
        startNewRound(forcedModifiers)
    end
end

function eventPlayerVampire(playerName, vampire)
    if isModifierActive('theresAVampireAmongUs') then
        doLater(function()
            tfm.exec.setVampirePlayer(playerName, false)
        end, 20, true)
    end
end

tfm.exec.disableAutoNewGame(true)

for playerName in pairs(tfm.get.room.playerList) do
    initPlayer(playerName)
end

startNewRound()