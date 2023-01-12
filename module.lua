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
    randomGhostObjects = {
        name = "Random ghost objects",
        description = "Every object summoned by the shaman will be randomly ghosted or not.",
        incompatibilities = {}
    },
    everyoneIsShaman = {
        name = "Everyone is shaman",
        description = "Everyone is shaman!",
        incompatibilities = {}
    }
}

modifierNames = {}
for modifierName, _ in pairs(modifiers) do
    modifierNames[#modifierNames + 1] = modifierName
end

math.randomseed(os.time())

activeModifiers = {}

function eventChatCommand(playerName, message)
    local args = {}
    for arg in message:gmatch("%S+") do
        args[#args + 1] = arg
    end
    local command = table.remove(args, 1)
end

function initPlayer(playerName)
    ui.addPopup(1, 0, "<p align='center'><font size='16'>Welcome to <b>Wacknilla</b>!</font></p>\nThis module is almost like normal vanilla.\nThe difference is that every round will have random modifiers added to it.", playerName, 250, 150, 300, true)
end

function eventNewPlayer(playerName)
	initPlayer(playerName)
    if getMiceAlive() < 3 then
        startNewRound()
    end
end

function eventPlayerDied(playerName)
    if getMiceAlive() == 0 then
        startNewRound()
    end
end

function eventLoop(currentTime, timeRemaining)
    if timeRemaining <= 0 then
        startNewRound()
    end
end

function eventSummoningEnd(playerName, objectType, xPosition, yPosition, angle, xSpeed, ySpeed, objectData)
    objectData.ghost = true
    if isModifierActive('randomGhostObjects') then
        objectData.ghost = true
        tfm.exec.removeObject(objectData.id)
        tfm.exec.addShamanObject(objectData.type, objectData.x, objectData.y, objectData.angle, objectData.vx, objectData.vy, (math.random(1, 2) == 1))
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
    for player, playerData in pairs(tfm.get.room.playerList) do
        if isModifierActive('miniMice') then
            tfm.exec.changePlayerSize(player, 0.4)
        elseif isModifierActive('hugeMice') then
            tfm.exec.changePlayerSize(player, 2.5)
        end

        if isModifierActive('everyoneIsShaman') then
            tfm.exec.setShaman(player, true)
            ui.setShamanName('Everyone!')
        end
    end
end

function canAddModifier(modifierName)
    for i, modifier in ipairs(activeModifiers) do
        if modifer == modifierName then
            return false
        end
        for j, incompatibility in ipairs(modifiers[modifier].incompatibilities) do
            if incompatibility == modifierName then
                return false
            end
        end
    end
    return true
end

function startNewRound()
    activeModifiers = {}

    local iterations = math.random(1, #modifierNames)

    for i = 1, iterations do
        local pickedModifier = modifierNames[math.random(1, #modifierNames)]
        if canAddModifier(pickedModifier) then
            activeModifiers[#activeModifiers + 1] = pickedModifier
        end
    end
    tfm.exec.setGameTime(2, true)
    tfm.exec.newGame(maps[math.random(0, #maps)])
end

function eventPlayerWon(playerName, timeElapsed, timeElapsedSinceRespawn)
    if getMiceAlive() == 0 then
        startNewRound()
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

tfm.exec.disableAutoNewGame(true)

for playerName in pairs(tfm.get.room.playerList) do
    initPlayer(playerName)
end

startNewRound()