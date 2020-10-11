local isThirst, isHungryFirst, isHungrySecond, isSprinting, isRunning, isArmed, isJumping, removeHealth = false, false, false, false, false, false, false, false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckStatus)
		TriggerEvent('esx_status:getStatus', 'thirst', function(status)
			if status.val < Config.ThirstRunBlock and status.val > 0 then
                isThirst = true
                removeHealth = false
                print("thirst "..status.val)
            elseif status.val == 0 then
                isThirst = false
                removeHealth = true
            else
                isThirst = false
                removeHealth = false
            end
        end)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
			if status.val <= Config.HungrySprintBlock and status.val >= (Config.HungryRunBlock + 1) then
                isHungryFirst = true
                isHungrySecond = false
                removeHealth = false
            elseif status.val <= Config.HungryRunBlock and status.val > 0 then
                isHungryFirst = false
                isHungrySecond = true
                removeHealth = false
            elseif status.val == 0 then
                isHungryFirst = false
                isHungrySecond = false
                removeHealth = true
            else
                isHungrySecond = false
                isHungryFirst = false
                removeHealth = false
			end
        end)
	end
end)

Citizen.CreateThread(function()
    local player        = PlayerPedId()
	while true do
        Citizen.Wait(0)

        if IsPedJumping(player) then
            isJumping = true
        else
            isJumping = false
        end

        if IsPedSprinting(player) then
			isSprinting = true
		else
			isSprinting = false
        end

        if IsPedRunning(player) then
            isRunning = true
        else
            isRunning = false
        end

        if isArmed then
            for k,v in pairs(Config.HungryBlockedWeapons) do
                if GetSelectedPedWeapon(player) == GetHashKey(v) then
                    DisableControlAction(0, 142, true)
                end
            end
        else
            EnableControlAction(0, 142, true)
        end

        if isThirst then
            if isRunning or isSprinting or isJumping then
                SetPedToRagdoll(player, 3000, 3000, 3, 0, 0, 0)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
                SetFlash(0, 0, 200, 1000, 500)
                effect()
                isThirst = false
            else
                effect()
                isThirst = false
            end
        end

        if isHungryFirst then
            if isSprinting then
                SetPedToRagdoll(player, 1000, 1000, 3, 0, 0, 0)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.1)
                SetFlash(0, 0, 200, 1000, 500)
                effect()
                isHungryFirst = false
            else
                effect()
                isHungryFirst = false
            end
        end

        if isHungrySecond then
            isArmed = true
            if isRunning or isJumping then
                SetPedToRagdoll(player, 1000, 1000, 3, 0, 0, 0)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.1)
                SetFlash(0, 0, 200, 1000, 500)
                effect()
                isHungrySecond = false
            else
                effect()
                isHungrySecond = false
            end
        else
            isArmed = false
        end
	end
end)

function effect()
    local player = PlayerPedId()
    SetPedMotionBlur(player, true)
    AnimpostfxPlay("DrugsMichaelAliensFightIn", 1000, true)
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
    Citizen.Wait(2000)
    AnimpostfxStop('DrugsMichaelAliensFightIn')
    AnimpostfxPlay("DrugsMichaelAliensFightOut", 1000, true)
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
    Citizen.Wait(2000)
    AnimpostfxStop('DrugsMichaelAliensFightOut')
    SetPedMotionBlur(player, false)
end


Citizen.CreateThread(function()
    local player        = PlayerPedId()
    local prevHealth    = GetEntityHealth(player)
    local health        = prevHealth
    while true do
        Citizen.Wait(1000)
        if removeHealth then
            if prevHealth <= 150 then
                health = health - 5
            else
                health = health - 1
            end

            if health ~= prevHealth then
				SetEntityHealth(player, health)
            end
        end
    end
end)