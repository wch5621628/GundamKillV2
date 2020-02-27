module("extensions.boss", package.seeall)
extension = sgs.Package("boss", sgs.Package_GeneralPack)

--获得G币
gainCoin = function(player, n)
	if n < 1 then return false end

	local room = player:getRoom()
	
	local json = require("json")
	local jsonValue = {
	player:objectName(),
	"yomeng"
	}
	local wholist = sgs.SPlayerList()
	wholist:append(player)
	room:doBroadcastNotify(wholist, sgs.CommandType.S_COMMAND_SET_EMOTION, json.encode(jsonValue))

	local log = sgs.LogMessage()
	log.type = "#coin"
	log.from = player
	log.arg = n
	room:sendLog(log)
	if n == 1 then
		room:broadcastSkillInvoke("gdsbgm", 7)
	else
		room:broadcastSkillInvoke("gdsbgm", 8)
	end
	
	local ip = room:getOwner():getIp()
	if player:getState() == "online" then
		room:setPlayerMark(player, "add_coin", n)
		room:askForUseCard(player, "@@luckyrecord!", "@luckyrecord")
		room:setPlayerMark(player, "add_coin", 0)
		room:setPlayerFlag(player, "-g2data_saved")
	end
end

function getWinner(victim)
    local room = victim:getRoom()
    local winner = ""

    if room:getMode() == "06_3v3" then
        local role = victim:getRoleEnum()
        if role == sgs.Player_Lord then
			winner = "renegade+rebel"
        elseif role == sgs.Player_Renegade then
			winner = "lord+loyalist"
        end
    elseif room:getMode() == "06_XMode" then
        local role = victim:getRole()
        local leader = victim:getTag("XModeLeader"):toPlayer()
        if leader:getTag("XModeBackup"):toStringList():isEmpty() then
            if role:startsWith("r") then
                winner = "lord+loyalist"
            else
                winner = "renegade+rebel"
			end
        end
    elseif room:getMode() == "08_defense" then
        local alive_roles = room:aliveRoles(victim)
        if not table.contains(alive_roles, "loyalist") then
            winner = "rebel"
        elseif not table.contains(alive_roles, "rebel") then
            winner = "loyalist"
		end
    elseif sgs.GetConfig("EnableHegemony", true) then
        local has_anjiang, has_diff_kingdoms = false, false
        local init_kingdom = ""
        for _,p in sgs.qlist(room:getAlivePlayers()) do
            if p:property("basara_generals"):toString() ~= "" then
                has_anjiang = true
			end
            if init_kingdom:isEmpty() then
                init_kingdom = p:getKingdom()
            elseif init_kingdom ~= p:getKingdom() then
                has_diff_kingdoms = true
			end
        end

        if not has_anjiang and not has_diff_kingdoms then
            local winners = {}
            local aliveKingdom = room:getAlivePlayers():first():getKingdom()
            for _,p in sgs.qlist(room:getPlayers()) do
                if p:isAlive() then
					table.insert(winners, p:objectName())
				end
                if p:getKingdom() == aliveKingdom then
                    local generals = p:property("basara_generals"):toString():split("+")
                    if #generals and sgs.GetConfig("Enable2ndGeneral", false) then continue end
                    if #generals > 1 then continue end

                    --if someone showed his kingdom before death,
                    --he should be considered victorious as well if his kingdom survives
                    table.insert(winners, p:objectName())
                end
            end
            winner = table.concat(winners, "+")
        end
        --[[if winner ~= "" then
            for _,player in sgs.qlist(room:getAllPlayers()) then
                if player:getGeneralName() == "anjiang" then
                    local generals = player:property("basara_generals"):toString():split("+")
                    room:changePlayerGeneral(player, generals[1])

                    room:setPlayerProperty(player, "kingdom", sgs.QVariant(player:getGeneral():getKingdom()))
                    room:setPlayerProperty(player, "role", BasaraMode::getMappedRole(player:getKingdom()))

                    generals.takeFirst()
                    player:setProperty("basara_generals", table.concat(generals, "+"))
                    room:notifyProperty(player, player, "basara_generals")
                end
                if sgs.GetConfig("Enable2ndGeneral", true) and player:getGeneral2Name() == "anjiang" then
                    local generals = player:property("basara_generals"):toString():split("+")
                    room:changePlayerGeneral2(player, generals[1])
                end
            end
        end]]--It is useless as it is irrelevant in LUA.
    else
        local alive_roles = room:aliveRoles(victim)
        local role = victim:getRoleEnum()
        if role == sgs.Player_Lord then
            if #alive_roles == 1 and alive_roles[1] == "renegade" then
                winner = room:getAlivePlayers():first():objectName()
            else
                winner = "rebel"
            end
        elseif role == sgs.Player_Rebel or role == sgs.Player_Renegade then
            if not table.contains(alive_roles, "rebel") and not table.contains(alive_roles, "renegade") then
                winner = "lord+loyalist"
            end
        else
        end
    end

    return winner
end

-- 通用效果：房主赢了可以选择重玩此局（联机刷币甚佳）
_mini_0_skill = sgs.CreateTriggerSkill{
	name = "_mini_0_skill",
	events = {sgs.GameOverJudge},
	priority = 0,
	global = true,
	can_trigger = function(self, player)
		local mode = player:getGameMode()
		if mode:startsWith("_mini_") then
			local n = string.gsub(mode, "_mini_", "")
			n = tonumber(n)
			return n >= 2
		end
		return false
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local owner = room:getOwner()
		local winner = getWinner(player) -- player is victim
		if winner ~= "" then
			if string.find(winner, owner:getRole()) or string.find(winner, owner:objectName())then
				local choice = room:askForChoice(owner, "restart_mini?", "restart_mini+next_mini", sgs.QVariant())
				if choice == "restart_mini" then
					room:setTag("NextGameMode", sgs.QVariant(player:getGameMode()))
				end
			end
		end
	end
}

-- 剧情效果：单挑谁赢谁拿10个G币而已
_mini_2_skill = sgs.CreateTriggerSkill{
	name = "_mini_2_skill",
	events = {sgs.GameOverJudge},
	priority = 1,
	global = true,
	can_trigger = function(self, player)
	    return player:getGameMode() == "_mini_2"
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _,p in sgs.qlist(room:getAllPlayers(true)) do
			if p:getState() == "online" and p:objectName() ~= player:objectName() then
				gainCoin(p, 10)
			end
		end
	end
}

-- 剧情效果：巴巴托斯会复活两次，第一次复活变身8/8天狼并获得技能“狂骨”，第二次复活变身12/12帝王并获得技能“血祭”
-- 反贼胜利可以拿10个G币，主公胜利不会拿（BOSS强度都让你嗨翻天了，还想当BOSS骗G币？）
_mini_3_skill = sgs.CreateTriggerSkill{
	name = "_mini_3_skill",
	events = {sgs.GameOverJudge, sgs.BuryVictim},
	priority = 1,
	global = true,
	can_trigger = function(self, player)
	    return player:getGameMode() == "_mini_3"
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:isLord() then
			if event == sgs.GameOverJudge then
				if player:getGeneralName() == "BARBATOS" then
					room:revivePlayer(player)
					return true
				elseif player:getGeneralName() == "LUPUS" then
					room:revivePlayer(player)
					return true
				else
					for _,p in sgs.qlist(room:getAllPlayers(true)) do
						if p:getState() == "online" then
							gainCoin(p, 10)
						end
					end
				end
			else
				if player:getGeneralName() == "BARBATOS" then
					room:changeHero(player, "LUPUS", true, true, false, true)
					room:setPlayerProperty(player, "maxhp", sgs.QVariant(8))
					room:setPlayerProperty(player, "hp", sgs.QVariant(8))
					player:throwAllCards()
					player:drawCards(8)
					if not player:faceUp() then
						player:turnOver()
					end
					if player:isChained() then
						room:setPlayerProperty(player, "chained", sgs.QVariant(false))
					end
					room:acquireSkill(player, "kuanggu")
					return true
				elseif player:getGeneralName() == "LUPUS" then
					room:changeHero(player, "REX", true, true, false, true)
					room:setPlayerProperty(player, "maxhp", sgs.QVariant(12))
					room:setPlayerProperty(player, "hp", sgs.QVariant(12))
					player:throwAllCards()
					player:drawCards(12)
					if not player:faceUp() then
						player:turnOver()
					end
					if player:isChained() then
						room:setPlayerProperty(player, "chained", sgs.QVariant(false))
					end
					room:acquireSkill(player, "xueji")
					return true
				end
			end
		end
	end
}

-- 剧情效果：清完杂兵后，原本两个穿藤甲的杂兵会复活成命运和传说
-- 主公/忠臣胜利可以拿10个G币
_mini_4_skill = sgs.CreateTriggerSkill{
	name = "_mini_4_skill",
	events = {sgs.GameOverJudge, sgs.BuryVictim},
	priority = 1,
	global = true,
	can_trigger = function(self, player)
	    return player:getGameMode() == "_mini_4"
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameOverJudge then
			if player:getKingdom() == "OMNI" and room:getLieges("OMNI", player):isEmpty() then
				local a, b = room:getAllPlayers(true):at(5), room:getAllPlayers(true):at(6)
				room:revivePlayer(a)
				room:revivePlayer(b)
				if a:objectName() == player:objectName() then
					room:setPlayerFlag(player, "_mini_4_destiny")
					room:changeHero(b, "LEGEND", true, true, false, true)
					b:drawCards(4)
					if not b:faceUp() then
						b:turnOver()
					end
					if b:isChained() then
						room:setPlayerProperty(b, "chained", sgs.QVariant(false))
					end
					return true
				elseif b:objectName() == player:objectName() then
					room:setPlayerFlag(player, "_mini_4_legend")
					room:changeHero(a, "DESTINY", true, true, false, true)
					a:drawCards(4)
					if not a:faceUp() then
						a:turnOver()
					end
					if a:isChained() then
						room:setPlayerProperty(a, "chained", sgs.QVariant(false))
					end
					return true
				else
					room:changeHero(a, "DESTINY", true, true, false, true)
					a:drawCards(4)
					if not a:faceUp() then
						a:turnOver()
					end
					if a:isChained() then
						room:setPlayerProperty(a, "chained", sgs.QVariant(false))
					end
					
					room:changeHero(b, "LEGEND", true, true, false, true)
					b:drawCards(4)
					if not b:faceUp() then
						b:turnOver()
					end
					if b:isChained() then
						room:setPlayerProperty(b, "chained", sgs.QVariant(false))
					end
					return true
				end
			elseif player:getKingdom() == "ZAFT" and room:getLieges("ZAFT", player):isEmpty() then
				for _,p in sgs.qlist(room:getAllPlayers(true)) do
					if p:getState() == "online" then
						gainCoin(p, 10)
					end
				end
			end
		else
			if player:hasFlag("_mini_4_destiny") then
				room:setPlayerFlag(player, "-_mini_4_destiny")
				room:changeHero(player, "DESTINY", true, true, false, true)
				player:throwAllCards()
				player:drawCards(4)
				if not player:faceUp() then
					player:turnOver()
				end
				if player:isChained() then
					room:setPlayerProperty(player, "chained", sgs.QVariant(false))
				end
				return true
			elseif player:hasFlag("_mini_4_legend") then
				room:setPlayerFlag(player, "-_mini_4_legend")
				room:changeHero(player, "LEGEND", true, true, false, true)
				player:throwAllCards()
				player:drawCards(4)
				if not player:faceUp() then
					player:turnOver()
				end
				if player:isChained() then
					room:setPlayerProperty(player, "chained", sgs.QVariant(false))
				end
				return true
			end
		end
	end
}

-- 剧情效果：若未出现双方均发动“明镜止水”的状态，甲方进入濒死状态时，其将体力回复至1点，然后乙方获得X个“怒”标记（X为甲方的体力回复量）
-- 胜利者可以拿10+Y个G币（Y为其“怒”标记数量）
_mini_5_skill = sgs.CreateTriggerSkill{
	name = "_mini_5_skill",
	events = {sgs.DrawInitialCards, sgs.EnterDying, sgs.GameOverJudge},
	priority = 1,
	global = true,
	can_trigger = function(self, player)
	    return player:getGameMode() == "_mini_5"
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			if player:isLord() then
				player:speak("Gundam Fight!Ready~Go!")
				player:getNextAlive():speak("Gundam Fight!Ready~Go!")
				room:broadcastSkillInvoke(self:objectName())
				room:getThread():delay(3500)
			end
		elseif event == sgs.EnterDying then
			for _,p in sgs.qlist(room:getAllPlayers(true)) do
				if p:getMark("@mingjingzhishui") == 0 and p:getMark("@m_mingjingzhishui") == 0 then
					local x = 1 - player:getHp()
					room:recover(player, sgs.RecoverStruct(player, nil, x))
					local oppo = player:getNextAlive()
					room:addPlayerMark(oppo, "@wrath", x)
					local log = sgs.LogMessage()
					log.type = "#_mini_5_skill"
					log.from = oppo
					log.to:append(player)
					log.arg = x
					log.arg2 = oppo:getMark("@wrath")
					room:sendLog(log)
					return false
				end
			end
		else
			for _,p in sgs.qlist(room:getAllPlayers(true)) do
				if p:getState() == "online" and p:objectName() ~= player:objectName() then
					gainCoin(p, 10 + p:getMark("@wrath"))
				end
			end
		end
	end
}

SHAMBLO = sgs.General(extension, "SHAMBLO", "ZEON", 8, false, true, true)

local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("_mini_0_skill") then skills:append(_mini_0_skill) end
if not sgs.Sanguosha:getSkill("_mini_2_skill") then skills:append(_mini_2_skill) end
if not sgs.Sanguosha:getSkill("_mini_3_skill") then skills:append(_mini_3_skill) end
if not sgs.Sanguosha:getSkill("_mini_4_skill") then skills:append(_mini_4_skill) end
if not sgs.Sanguosha:getSkill("_mini_5_skill") then skills:append(_mini_5_skill) end
sgs.Sanguosha:addSkills(skills)

sgs.LoadTranslationTable{
	["boss"] = "BOSS",
	["restart_mini?"] = "重玩此局？",
	["restart_mini"] = "重玩",
	["next_mini"] = "下一局",
	["#_mini_5_skill"] = "<b><font color='yellow'>剧情效果</font></b>：由于未出现双方均发动“<b><font color='yellow'>明镜止水</font></b>”的状态，%to 继续战斗！<br>%from 得到了 %arg 枚 <b><font color='yellow'>怒</font></b> 标记，胜利后可额外获得 %arg2 枚G币",
	
	["SHAMBLO"] = "尚布罗",
	["#SHAMBLO"] = "重力的井底",
	["~SHAMBLO"] = "",
	["designer:SHAMBLO"] = "高达杀制作组",
	["cv:SHAMBLO"] = "罗妮·贾维",
	["illustrator:SHAMBLO"] = "wch5621628",
}