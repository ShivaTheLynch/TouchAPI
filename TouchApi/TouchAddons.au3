#include-once
#include "../constants/constants.au3"

; Add missing rarity constant at the top of the file
Global Const $rarity_gray = 2620

;~ All Weapon mods
Global $Weapon_Mod_Array[25] = [893, 894, 895, 896, 897, 905, 906, 907, 908, 909, 6323, 6331, 15540, 15541, 15542, 15543, 15544, 15551, 15552, 15553, 15554, 15555, 17059, 19122, 19123]

;~ General Items
Global $General_Items_Array[6] = [2989, 2991, 2992, 5899, 5900, 22751]
Global Const $ITEM_ID_Lockpicks = 22751

;~ Dyes
Global Const $ITEM_ID_Dyes = 146
Global Const $ITEM_ExtraID_BlackDye = 10
Global Const $ITEM_ExtraID_WhiteDye = 12

Global $Array_pscon[39]=[910, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 35124, 36682, 6376, 21809, 21810, 21813, 36683, 21492, 21812, 22269, 22644, 22752, 28436,15837, 21490, 30648, 31020, 6370, 21488, 21489, 22191, 26784, 28433, 5656, 18345, 21491, 37765, 21833, 28433, 28434]




#Region Inventory
Func GetNicholasItemCount()
    Local $AAMOUNTNicholasItem = 0
    Local $lItemArray = GetItemArray()

    For $i = 1 To $lItemArray[0]
        Local $lItemPtr = $lItemArray[$i]
        If GetItemInfoByPtr($lItemPtr, "ModelID") = $NicholasItemID Then
            $AAMOUNTNicholasItem += GetItemInfoByPtr($lItemPtr, "Quantity")
        EndIf
    Next

    Return $AAMOUNTNicholasItem
EndFunc	;==>GetNicholasItemCount

Func GetNicholasCollectorItemCount()
	Local $AAMOUNTNicholasItem = 0
    Local $lItemArray = GetItemArray()

    For $i = 1 To $lItemArray[0]
        Local $lItemPtr = $lItemArray[$i]
        If GetItemInfoByPtr($lItemPtr, "ModelID") = $CollectorItemID Then
            $AAMOUNTNicholasItem += GetItemInfoByPtr($lItemPtr, "Quantity")
        EndIf
    Next

    Return $AAMOUNTNicholasItem
EndFunc   ; Counts Nicholas Items in your Inventory
Func GetNearestNPCToAgent($aAgentID = -2, $aRange = 1320, $aType = 0xDB, $aReturnMode = 1, $aCustomFilter = "NPCFilter")
	Return GetAgents($aAgentID, $aRange, $aType, $aReturnMode, $aCustomFilter)
EndFunc	;==>GetNearestNPCToAgent
Func GetNicholasGiftCount()
	Local $AAMOUNTNicholasItem = 0
    Local $lItemArray = GetItemArray()

    For $i = 1 To $lItemArray[0]
        Local $lItemPtr = $lItemArray[$i]
        If GetItemInfoByPtr($lItemPtr, "ModelID") = $NicholasGiftID Then
            $AAMOUNTNicholasItem += GetItemInfoByPtr($lItemPtr, "Quantity")
        EndIf
    Next

    Return $AAMOUNTNicholasItem
EndFunc   ; Counts Nicholas Gifts in your Inventory

Func GetNumberOfLockpicks()
	Local $AAMOUNTLockpicks = 0
	Local $lItemArray = GetItemArray()
	Local $ItemModelID
	Local $LockpickQuantity

	For $i = 1 To $lItemArray[0]
		Local $lItemPtr = $lItemArray[$i]
		$ItemModelID = GetItemInfoByPtr($lItemPtr, "ModelID")
		If $ItemModelID == $ITEM_ID_Lockpicks Then
			$LockpickQuantity = GetItemInfoByPtr($lItemPtr, "Quantity")
			Sleep(16)
			$AAMOUNTLockpicks += $LockpickQuantity
		EndIf
	Next

	Return $AAMOUNTLockpicks
EndFunc	   ; Counts Lockpicks in your Inventory

Func CountSlots()
	Local $bag
	Local $temp = 0
	For $i = 1 To 4
		$bag = GetBagPtr($i)
		$temp += GetBagInfo($bag,"EmptySlots")
	Next
	Return $temp
EndFunc ; Counts open slots in your Inventory

Func PickUpLoot()
	If GetIsDead(-2) Then Return
    Local $lAgentArray = GetItemArray()
    Local $maxitems = $lAgentArray[0]

    For $i = 1 To $maxitems
		If GetIsDead(-2) Then Exitloop
        Local $aItemPtr = $lAgentArray[$i]
        Local $aItemAgentID = GetItemInfoByPtr($aItemPtr, "AgentID")

        If GetIsDead(-2) Then Exitloop
        If $aItemAgentID = 0 Then ContinueLoop ; If Item is not on the ground

        If CanPickUp($aItemPtr) Then
			; --- Gold pickup logic ---
			Local $lModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
			If $lModelID = 2511 Then ; Gold coin model ID
				Local $goldBefore = GetGoldCharacter()
				PickUpItem($aItemAgentID)
				Local $lDeadlock = TimerInit()
				While GetItemAgentExists($aItemAgentID)
					Sleep(100)
					If GetIsDead(-2) Then Exitloop
					If TimerDiff($lDeadlock) > 10000 Then ExitLoop
				WEnd
				Local $goldAfter = GetGoldCharacter()
				Local $goldDiff = $goldAfter - $goldBefore
				If $goldDiff > 0 And IsDeclared("$Stat_GoldPickedUp") Then
					$Stat_GoldPickedUp += $goldDiff
					If IsDeclared("UpdateStatisticsDisplay") Then UpdateStatisticsDisplay()
				EndIf
			Else
				PickUpItem($aItemAgentID)
				Local $lDeadlock = TimerInit()
				While GetItemAgentExists($aItemAgentID)
					Sleep(100)
					If GetIsDead(-2) Then Exitloop
					If TimerDiff($lDeadlock) > 10000 Then ExitLoop
				WEnd
			EndIf
        EndIf
    Next
EndFunc   ;==>PickUpLoot

;~ Description: Test if an Item agent exists.
Func GetItemAgentExists($aItemAgentID)
	Return (GetAgentPtr($aItemAgentID) > 0 And $aItemAgentID < GetMaxItems())
EndFunc   ;==>GetItemAgentExists

Func CanPickUp($aItemPtr)
    Local $lModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
    Local $aExtraID = GetItemInfoByPtr($aItemPtr, "Dye1")
    Local $lRarity = GetItemInfoByPtr($aItemPtr, "Rarity")
    ; Only use rarity and special item logic
    Local $GUIExists = True
    If Not IsDeclared("GUIPickupGoldCheckbox") Then $GUIExists = False

    ; Gold coins (only pick if character has less than 99k in inventory)
    If ($lModelID == 2511) And (GetGoldCharacter() < 99000) Then
        Return True
    EndIf

    ; Dyes - check GUI setting if available
    If ($lModelID == $ITEM_ID_Dyes) Then
        If $GUIExists And GUICtrlRead($GUIPickupDyesCheckbox) = $GUI_CHECKED Then
            If (($aExtraID == $ITEM_ExtraID_BlackDye) Or ($aExtraID == $ITEM_ExtraID_WhiteDye)) Then
                Return True
            EndIf
        ElseIf Not $GUIExists Then
            If (($aExtraID == $ITEM_ExtraID_BlackDye) Or ($aExtraID == $ITEM_ExtraID_WhiteDye)) Then
                Return True
            EndIf
        EndIf
        Return False
    EndIf

    ; Rarity-based filtering
    If $GUIExists Then
        Switch $lRarity
            Case $rarity_gold ; Gold items
                If GUICtrlRead($GUIPickupGoldCheckbox) = $GUI_CHECKED Then
                    Return True
                EndIf
            Case $rarity_purple ; Purple items
                If GUICtrlRead($GUIPickupPurpleCheckbox) = $GUI_CHECKED Then
                    Return True
                EndIf
            Case $rarity_blue ; Blue items
                If GUICtrlRead($GUIPickupBlueCheckbox) = $GUI_CHECKED Then
                    Return True
                EndIf
            Case $rarity_green ; Green items
                If GUICtrlRead($GUIPickupGreenCheckbox) = $GUI_CHECKED Then
                    Return True
                EndIf
            Case $rarity_white ; White items
                If GUICtrlRead($GUIPickupWhiteCheckbox) = $GUI_CHECKED Then
                    Return True
                EndIf
        EndSwitch
    Else
        If ($lRarity == $rarity_gold) Then
            Return True
        ElseIf ($lRarity == $rarity_purple) Then
            Return False
        EndIf
    EndIf

    ; Special items that should always be picked up regardless of GUI settings
    If ($lModelID == $ITEM_ID_Lockpicks) Then
        Return True ; Lockpicks
    ElseIf $lModelID == 22269 Then
        Return True ; Cupcakes
    ElseIf CheckArrayPscon($lModelID) Then
        Return True ; Pcons
    ElseIf IsRareMaterial($aItemPtr) Then
        Return True ; Rare Materials
    ElseIf $lModelID == 522 Then
        Return True ; Dark Remains
    ElseIf $lModelID == 19187 Then
        Return True ; Ruby Djinn Essence
    ElseIf $lModelID == 19186 Then
        Return True ; Diamond Djinn Essence
    ElseIf $lModelID == 19188 Then
        Return True ; Sapphire Djinn Essence
    ElseIf $lModelID == 19189 Then
        Return True ; Water Djinn Essence
    EndIf

    ; Materials
    If $GUIExists And IsMaterial($aItemPtr) Then
        If GUICtrlRead($GUIPickupMaterialsCheckbox) = $GUI_CHECKED Then
            Return True
        EndIf
    EndIf
    ; Keys
    If $GUIExists And IsKey($aItemPtr) Then
        If GUICtrlRead($GUIPickupKeysCheckbox) = $GUI_CHECKED Then
            Return True
        EndIf
    EndIf
    ; Scrolls
    If $GUIExists And IsScroll($aItemPtr) Then
        If GUICtrlRead($GUIPickupScrollsCheckbox) = $GUI_CHECKED Then
            Return True
        EndIf
    EndIf
    ; Consumables
    If $GUIExists And IsConsumable($aItemPtr) Then
        If GUICtrlRead($GUIPickupConsumablesCheckbox) = $GUI_CHECKED Then
            Return True
        EndIf
    EndIf
    Return False
EndFunc   ;==>CanPickUp

; Helper functions for item type detection
Func IsMaterial($aItemPtr)
	Local $lModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
	; Common material IDs - using constants from constants.au3
	Local $MaterialIDs[20] = [$model_id_ruby, $model_id_sapphire, $model_id_diamond, $model_id_monstrous_eye, $model_id_monstrous_fang, $model_id_onyx, $model_id_ecto, $model_id_obsidian_shard, $model_id_monstrous_claw, $model_id_steel_ingot, $model_id_fur_square, $model_id_leather_square, $model_id_elonian_leather_square, $model_id_vial_of_ink, $model_id_deldrimor_steel_ingot, $model_id_roll_of_parchment, $model_id_roll_of_vellum, $model_id_spiritwood_plank, $model_id_amber_chunk, $model_id_jadeit_shard]
	For $i = 0 To UBound($MaterialIDs) - 1
		If $lModelID == $MaterialIDs[$i] Then Return True
	Next
	Return False
EndFunc

Func IsKey($aItemPtr)
	Local $lModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
	; Common key IDs - using constants where available
	Local $KeyIDs[10] = [$ITEM_ID_Lockpicks, 22752, 22753, 22754, 22755, 22756, 22757, 22758, 22759, 22760]
	For $i = 0 To UBound($KeyIDs) - 1
		If $lModelID == $KeyIDs[$i] Then Return True
	Next
	Return False
EndFunc

Func IsScroll($aItemPtr)
	Local $lModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
	; Common scroll IDs - using constants from constants.au3
	Local $ScrollIDs[10] = [$model_id_uw_scroll, $model_id_fow_scroll, 22281, 22282, 22283, 22284, 22285, 22286, 22287, 22288]
	For $i = 0 To UBound($ScrollIDs) - 1
		If $lModelID == $ScrollIDs[$i] Then Return True
	Next
	Return False
EndFunc

Func IsConsumable($aItemPtr)
	Local $lModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
	; Check if it's in the pcons array
	Return CheckArrayPscon($lModelID)
EndFunc

Func CheckArrayPscon($lModelID)
	For $p = 0 To (UBound($Array_pscon) -1)
		If ($lModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc   ;==>CheckArrayPscon
Func FindIdentificationKit()
	Local $lItemPtr
	Local $lKit = 0
	Local $lKitPtr = 0
	Local $lUses = 101
	For $i = 1 To 4
		For $j = 1 To GetBagInfo(GetBagPtr($i), 'Slots')
			$lItemPtr = GetItemBySlot($i, $j)
			Switch GetItemInfoByPtr($lItemPtr, 'ModelID')
				Case 2989
					If GetItemInfoByPtr($lItemPtr, 'Value') / 2 < $lUses Then
						$lKit = GetItemInfoByPtr($lItemPtr, 'ItemID')
						$lUses = GetItemInfoByPtr($lItemPtr, 'Value') / 2
						$lKitPtr = $lItemPtr
					EndIf
				Case 5899
					If GetItemInfoByPtr($lItemPtr, 'Value') / 2.5 < $lUses Then
						$lKit = GetItemInfoByPtr($lItemPtr, 'ItemID')
						$lUses = GetItemInfoByPtr($lItemPtr, 'Value') / 2.5
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindIdentificationKit

Func Inventory()
	Out("Travel to Eye ")
	;TravelGH()
	;WaitMapLoading()
	Out("Travelling to Eye of the North")
	RndTravel($MAP_ID_EYE_OF_THE_NORTH )

	$inventorytrigger = 1

	;Out("Checking Guild Hall")
	;CheckGuildHall()
	sleep(1000)

	Out("Move to Merchant")
	;Merchant()
	MerchantEotN()
	sleep(2000)

	Out("Identifying")
	For $i = 1 To 4
		Ident($i)
	Next

	Out("Selling")
	For $i = 1 To 4
		Sell($i)
	Next

	For $i = 1 To 4
		Sell2($i)
	Next

	If GetGoldCharacter() > 90000 Then
		Out("Depositing Gold")
		DepositGold()
	EndIf

	If FindRareRuneOrInsignia() <> 0 Then
		Out("Salvage all Runes")
		For $i = 1 To 4
			Salvage($i)
		Next
		Out("Second Round of Salvage")
		For $i = 1 To 4
			Salvage($i)
		Next

		Out("Sell leftover items")
		For $i = 1 To 4
			Sell($i)
		Next

		For $i = 1 To 4
			Sell2($i)
		Next
	EndIf

	While FindRareRuneOrInsignia() <> 0
		Out("Move to Rune Trader")
		;RuneTrader()
		RuneTraderEotN()
		Sleep(2000)

		Out("Sell Runes")
		For $i = 1 To 4
			SellRunes($i)
		Next
		Sleep(2000)

		If GetGoldCharacter() > 20000 Then
			;MoveTo(907.45,11489.51)
			Out("Buying Rare Materials")
			;RareMaterialTrader(),
			RareMaterialTraderEotN()
		EndIf
	WEnd

	sleep(3000)
	RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)  ; Travel back to Fort Aspenwood after inventory is complete
EndFunc ;==> Inventory
Func Merchant()
	;~ Array with Coordinates for Merchants (you better check those for your own Guildhall)
	Dim $Waypoints_by_Merchant[29][3] = [ _
			[$BurningIsle, -4439, -2088], _
			[$BurningIsle, -4772, -362], _
			[$BurningIsle, -3637, 1088], _
			[$BurningIsle, -2506, 988], _
			[$DruidsIsle, -2037, 2964], _
			[$FrozenIsle, 99, 2660], _
			[$FrozenIsle, 71, 834], _
			[$FrozenIsle, -299, 79], _
			[$HuntersIsle, 5156, 7789], _
			[$HuntersIsle, 4416, 5656], _
			[$IsleOfTheDead, -4066, -1203], _
			[$NomadsIsle, 5129, 4748], _
			[$WarriorsIsle, 4159, 8540], _
			[$WarriorsIsle, 5575, 9054], _
			[$WizardsIsle, 4288, 8263], _
			[$WizardsIsle, 3583, 9040], _
			[$ImperialIsle, 1415, 12448], _
			[$ImperialIsle, 1746, 11516], _
			[$IsleOfJade, 8825, 3384], _
			[$IsleOfJade, 10142, 3116], _
			[$IsleOfMeditation, -331, 8084], _
			[$IsleOfMeditation, -1745, 8681], _
			[$IsleOfMeditation, -2197, 8076], _
			[$IsleOfWeepingStone, -3095, 8535], _
			[$IsleOfWeepingStone, -3988, 7588], _
			[$CorruptedIsle, -4670, 5630], _
			[$IsleOfSolitude, 2970, 1532], _
			[$IsleOfWurms, 8284, 3578], _
			[$UnchartedIsle, 1503, -2830]]
	For $i = 0 To (UBound($Waypoints_by_Merchant) - 1)
		If ($Waypoints_by_Merchant[$i][0] == True) Then
			MoveTo($Waypoints_by_Merchant[$i][1], $Waypoints_by_Merchant[$i][2])
		EndIf
	Next

	Out("Talk to Merchant")
	Local $guy = GetNearestNPCToAgent(-2, 1320, 0xDB, 1, "NPCFilter")
	MoveTo(GetAgentInfo($guy, "X")-20,GetAgentInfo($guy, "Y")-20)
    GoNPC($guy)
    Sleep(1000)
EndFunc ;==> Merchant

Func MerchantEotN()
	; Run to Merchant in EotN
	Out("Run to Merchant in EotN")
	MoveTo(-2660.77, 1162.44)

	Out("Talk to Merchant")
	Local $guy = GetNearestNPCPtrToAgent(-2)
	If $guy Then
		MoveTo(X($guy)-20, Y($guy)-20)
		GoNPC($guy)
		Sleep(1000)
	Else
		Out("No merchant found!")
	EndIf
EndFunc ;==> MerchantEotN

Func RareMaterialTrader()
	;~ Array with Coordinates for Merchants (you better check those for your own Guildhall)
	Dim $Waypoints_by_RareMatTrader[36][3] = [ _
			[$BurningIsle, -3793, 1069], _
			[$BurningIsle, -2798, -74], _
			[$DruidsIsle, -989, 4493], _
			[$FrozenIsle, 71, 834], _
			[$FrozenIsle, 99, 2660], _
			[$FrozenIsle, -385, 3254], _
			[$FrozenIsle, -983, 3195], _
			[$HuntersIsle, 3267, 6557], _
			[$IsleOfTheDead, -3415, -1658], _
			[$NomadsIsle, 1930, 4129], _
			[$NomadsIsle, 462, 4094], _
			[$WarriorsIsle, 4108, 8404], _
			[$WarriorsIsle, 3403, 6583], _
			[$WarriorsIsle, 3415, 5617], _
			[$WizardsIsle, 3610, 9619], _
			[$ImperialIsle, 244, 11719], _
			[$IsleOfJade, 8919, 3459], _
			[$IsleOfJade, 6789, 2781], _
			[$IsleOfJade, 6566, 2248], _
			[$IsleOfMeditation, -2197, 8076], _
			[$IsleOfMeditation, -1745, 8681], _
			[$IsleOfMeditation, -331, 8084], _
			[$IsleOfMeditation, 422, 8769], _
			[$IsleOfMeditation, 549, 9531], _
			[$IsleOfWeepingStone, -3988, 7588], _
			[$IsleOfWeepingStone, -3095, 8535], _
			[$IsleOfWeepingStone, -2431, 7946], _
			[$IsleOfWeepingStone, -1618, 8797], _
			[$CorruptedIsle, -4424, 5645], _
			[$CorruptedIsle, -4443, 4679], _
			[$IsleOfSolitude, 3172, 3728], _
			[$IsleOfSolitude, 3221, 4789], _
			[$IsleOfSolitude, 3745, 4542], _
			[$IsleOfWurms, 8353, 2995], _
			[$IsleOfWurms, 6708, 3093], _
			[$UnchartedIsle, 2530, -2403]]
	For $i = 0 To (UBound($Waypoints_by_RareMatTrader) - 1)
		If ($Waypoints_by_RareMatTrader[$i][0] == True) Then
			MoveTo($Waypoints_by_RareMatTrader[$i][1], $Waypoints_by_RareMatTrader[$i][2])
		EndIf
	Next
	Out("Talk to Rare Material Trader")
	Local $guy = GetNearestNPCToAgent(-2, 1320, 0xDB, 1, "NPCFilter")
	MoveTo(GetAgentInfo($guy, "X")-20,GetAgentInfo($guy, "Y")-20)
    GoNPC($guy)
    Sleep(1000)
	;~This section does the buying
	;TraderRequest(930)  ;~ Ectos
	While GetGoldStorage() > 900*1000 Or GetGoldCharacter() > 10*1000
		If GetGoldCharacter() > 10*1000 Then
			TraderRequest(930)
			Sleep(500)
			TraderBuy()
			Sleep(500)
		Elseif GetGoldStorage() > 900*1000 Then
			WithdrawGold()
			Sleep(1000)
		EndIf
	WEnd
EndFunc	;==>Rare Material trader

Func RareMaterialTraderEotN()
	Out("Run to Rare Material Trader in EotN")
	MoveTo(-2216.90, 1083.70)

	Out("Talk to Rare Material Trader")
	Local $guy = GetNearestNPCPtrToAgent(-2)
	If $guy Then
		MoveTo(X($guy)-20, Y($guy)-20)
		GoNPC($guy)
		Sleep(1000)
	Else
		Out("No rare material trader found!")
	EndIf
	
	;~This section does the buying
	While GetGoldStorage() > 900*1000 Or GetGoldCharacter() > 10*1000
		If GetGoldCharacter() > 10*1000 Then
			TraderRequest(930)
			Sleep(500)
			TraderBuy()
			Sleep(500)
		Elseif GetGoldStorage() > 900*1000 Then
			WithdrawGold()
			Sleep(1000)
		EndIf
	WEnd
EndFunc	;==> RareMaterialTraderEotN

Func RuneTrader()
	MoveTo(1297.07,11389.97)
	MoveTo(905.74,11655.34)
	Out("Talk to Rune Trader")
	Local $guy = GetNearestNPCToAgent(-2, 1320, 0xDB, 1, "NPCFilter")
	MoveTo(GetAgentInfo($guy, "X")-20,GetAgentInfo($guy, "Y")-20)
    GoNPC($guy)
    Sleep(1000)
EndFunc	;==> Rune Trader

Func RuneTraderEotN()
	Out("Run to Rune Trader in EotN")
	MoveTo(-3250.18, 2011.88)

	Out("Talk to Rune Trader")
	Local $guy = GetNearestNPCPtrToAgent(-2)
	If $guy Then
		MoveTo(X($guy)-20, Y($guy)-20)
		GoNPC($guy)
		Sleep(1000)
	Else
		Out("No rune trader found!")
	EndIf
EndFunc ;==> RuneTraderEotN

Func Ident($BagIndex)
	Local $BagPtr
	Local $aItemPtr
	$BagPtr = GetBagPtr($BagIndex)
	For $ii = 1 To GetBagInfo($BagPtr, "Slots")
		If FindIdentificationKit() = 0 Then
			If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
				WithdrawGold(500)
				Sleep(1000)
			EndIf
			Local $j = 0
			Do
				BuyItem(6, 1, 500)
				Sleep(1000)
				$j = $j + 1
			Until FindIdentificationKit() <> 0 Or $j = 3
			If $j = 3 Then ExitLoop
			Sleep(1000)
		EndIf
		$aItemPtr = GetItemBySlot($BagIndex, $ii)
		If GetItemInfoByPtr($aItemPtr, "ItemID") = 0 Then ContinueLoop
		If GetItemInfoByPtr($aItemPtr, "IsIdentified") Then ContinueLoop
		IdentifyItem2($aItemPtr, FindIdentificationKit())
		Sleep(250)
	Next
EndFunc ;==>Ident

; Function to check if an item should be salvaged based on Salvage tab GUI
Func CanSalvageByGui($aItemPtr)
    Local $lRarity = GetItemInfoByPtr($aItemPtr, "Rarity")
    ; Only use rarity checkboxes
    If $lRarity = $rarity_gold And GUICtrlRead($GUISalvageGoldCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_purple And GUICtrlRead($GUISalvagePurpleCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_blue And GUICtrlRead($GUISalvageBlueCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_green And GUICtrlRead($GUISalvageGreenCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_white And GUICtrlRead($GUISalvageWhiteCheckbox) = $GUI_CHECKED Then Return True
    Return False
EndFunc

; Function to check if an item should be sold based on Sell tab GUI
Func CanSellByGui($aItemPtr)
    Local $lRarity = GetItemInfoByPtr($aItemPtr, "Rarity")
    ; Only use rarity checkboxes
    If $lRarity = $rarity_gold And GUICtrlRead($GUISellGoldCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_purple And GUICtrlRead($GUISellPurpleCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_blue And GUICtrlRead($GUISellBlueCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_green And GUICtrlRead($GUISellGreenCheckbox) = $GUI_CHECKED Then Return True
    If $lRarity = $rarity_white And GUICtrlRead($GUISellWhiteCheckbox) = $GUI_CHECKED Then Return True
    Return False
EndFunc

; Update Salvage routine to use CanSalvageByGui
Func Salvage($BagIndex)
    Local $BagPtr
    Local $aItemPtr
    $BagPtr = GetBagPtr($BagIndex)
    For $ii = 1 To GetBagInfo($BagPtr, "Slots")
        If FindExpertSalvageKit() = 0 Then
            If GetGoldCharacter() < 400 And GetGoldStorage() > 399 Then
                WithdrawGold(400)
                Sleep(1000)
            EndIf
            Local $j = 0
            Do
                BuyItem(3, 1, 400)
                Sleep(1000)
                $j = $j + 1
            Until FindExpertSalvageKit() <> 0 Or $j = 3
            If $j = 3 Then ExitLoop
            Sleep(1000)
        EndIf
        $aItemPtr = GetItemBySlot($BagIndex, $ii)
        If GetItemInfoByPtr($aItemPtr, "ItemID") = 0 Then ContinueLoop
        ; Use new GUI logic for salvage
        If CanSalvageByGui($aItemPtr) Then
            If IsAlreadySalvaged($aItemPtr) Then ContinueLoop
            StartSalvage2($aItemPtr, FindExpertSalvageKit())
            Sleep(500)
            SalvageMod(1)
            Sleep(500)
        ElseIf IsRareRune($aItemPtr) Then
            If IsAlreadySalvaged($aItemPtr) Then ContinueLoop
            StartSalvage2($aItemPtr, FindExpertSalvageKit())
            Sleep(500)
            SalvageMod(1)
            Sleep(500)
        ElseIf IsRareInsignia($aItemPtr) Then
            If IsAlreadySalvaged($aItemPtr) Then ContinueLoop
            StartSalvage2($aItemPtr, FindExpertSalvageKit())
            Sleep(500)
            SalvageMod(0)
            Sleep(500)
        Else
            ContinueLoop
        EndIf
    Next
EndFunc

; Update Sell routine to use CanSellByGui
Func Sell2($BagIndex)
    Local $aItemPtr
    Local $BagPtr = GetBagPtr($BagIndex)
    For $ii = 1 To GetBagInfo($BagPtr, "Slots")
        $aItemPtr = GetItemBySlot($BagIndex, $ii)
        If GetItemInfoByPtr($aItemPtr, "ItemID") = 0 Then ContinueLoop
        ; Use new GUI logic for sell
        If CanSellByGui($aItemPtr) Then
            SellItem($aItemPtr)
        EndIf
        Sleep(250)
    Next
EndFunc ;==> Sell2

Func IsAlreadySalvaged($aItemPtr)
	Local $modelID
	If Not IsPtr($aItemPtr) Then $aItemPtr = GetItemPtr($aItemPtr)
	
	$modelID = GetItemInfoByPtr($aItemPtr, "ModelID")
	Switch $modelID
		Case 5551	;~ Sup Vigor
			Return True
		Case 903	;~ minor Strength, minor Tactics
			Return True
		Case 904	;~ minor Expertise, minor Marksman
			Return True
		Case 902	;~ minor Healing, minor Prot, minor Divine
			Return True
		Case 900	;~ minor Soul
			Return True
		Case 899	;~ minor Fastcast, minor Insp
			Return True
		Case 901	;~ minor Energy
			Return True
		Case 6327	;~ minor Spawn
			Return True
		Case 15545	;~ minor Scythe, minor Mystic
			Return True
		Case 898	;~ minor Vigor, minor Vitae
			Return True
		Case 3612	;~ major Fastcast
			Return True
		Case 5550	;~ major Vigor
			Return True
		Case 5557	;~ superior Smite
			Return True
		Case 5553	;~ superior Death
			Return True
		Case 5549	;~ superior Dom
			Return True
		Case 5555	;~ superior Air
			Return True
		Case 6329	;~ superior Channel, superior Commu
			Return True
		Case 5551	;~ superior Vigor
			Return True
		Case 19156	;~ Sentinel insignia
			Return True
		Case 19139	;~ Tormentor insignia
			Return True
		Case 19163	;~ Winwalker insignia
			Return True
		Case 19129	;~ Prodigy insignia
			Return True
		Case 19165	;~ Shamans insignia
			Return True
		Case 19127	;~ Nightstalker insignia
			Return True
		Case 19168	;~ Centurions insignia
			Return True
		Case 19135	;~ Blessed insignia
			Return True
	EndSwitch

	Return False
EndFunc	;==> IsAlreadySalvaged
Func FindRareRuneOrInsignia()
	Local $lItemPtr
	For $i = 1 To 4
		For $j = 1 To GetBagInfo(GetBagPtr($i), 'Slots')
			$lItemPtr = GetItemBySlot($i, $j)
			If IsRareRune($lItemPtr) Or IsRareInsignia($lItemPtr) Then Return True
		Next
	Next
	Return False
EndFunc	   ;==>FindSellableRune

Func Sell($BagIndex)
	Local $aItemPtr
	Local $BagPtr = GetBagPtr($BagIndex)
	For $ii = 1 To GetBagInfo($BagPtr, "Slots")
		$aItemPtr = GetItemBySlot($BagIndex, $ii)
		If GetItemInfoByPtr($aItemPtr, "ItemID") = 0 Then ContinueLoop
		Local $sellable = CanSell($aItemPtr)
		Sleep(500)
		If $sellable Then
			SellItem($aItemPtr)
		EndIf
		Sleep(250)
	Next
EndFunc ;==> Sell

Func ScanDyes($dyeID)
	Local $aItemPtr
	Local $BagIndex
	Local $BagPtr
	Local $dyeNumber = 0
	Local $ModelID 
	Local $ExtraID

	For $BagIndex = 1 To 4
		$BagPtr = GetBagPtr($BagIndex)
		For $ii = 1 To GetBagInfo($BagPtr, "Slots")
			$aItemPtr = GetItemBySlot($BagIndex, $ii)
			If GetItemInfoByPtr($aItemPtr, "ItemID") = 0 Then ContinueLoop
			$ModelID = GetItemInfoByPtr($aItemPtr, "ModelID")
			$ExtraID = GetItemInfoByPtr($aItemPtr, "Dye1")
			If $ModelID == 146 and $ExtraID == $dyeID Then
				$dyeNumber += GetItemInfoByPtr($aItemPtr, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $dyeNumber
EndFunc ;==> ScanDyes


Func SellRunes($BagIndex)
	Local $aItemPtr
	Local $BagPtr = GetBagPtr($BagIndex)
	For $ii = 1 To GetBagInfo($BagPtr, "Slots")
		$aItemPtr = GetItemBySlot($BagIndex, $ii)
		If GetItemInfoByPtr($aItemPtr, "ItemID") = 0 Then ContinueLoop
		Local $sellable = IsSellableInsignia($aItemPtr) + IsSellableRune($aItemPtr)
		Sleep(250)
		If $sellable > 0 Then
			if GetGoldCharacter() > 65000 and GetGoldStorage() <= 935000 Then
				DepositGold(65000)
				Sleep(500)
			ElseIf GetGoldCharacter() > 65000 and GetGoldStorage() > 935000 Then
				ExitLoop
			EndIf

			If IsSupVigor($aItemPtr) Then
				If GetGoldCharacter() > 20000 Then DepositGold()
				Sleep(500)
				If GetGoldCharacter() > 20000 Then ContinueLoop
			EndIf

			TraderRequestSell($aItemPtr)
			Sleep(500)
			TraderSell()
			Sleep(500)
		EndIf
		Sleep(500)
	Next
EndFunc ;==> SellRunes

Func CanSell($aitem)

	Local $RareSkin = IsRareSkin($aItem)
	Local $Pcon = IsPcon($aItem)
	Local $Material = IsRareMaterial($aItem)
	Local $IsSpecial = IsSpecialItem($aItem)
	Local $IsCaster = IsPerfectCaster($aItem)
	Local $IsStaff = IsPerfectStaff($aItem)
	Local $IsShield = IsPerfectShield($aItem)
	Local $IsRune = IsRareRune($aItem)
	Local $IsReq8 = IsReq8Max($aItem)
	Local $IsReq7 = IsReq7Max($aItem)
	Local $IsTome = IsRegularTome($aItem)
	Local $IsEliteTome = IsEliteTome($aItem)
	Local $IsFiveE = IsFiveE($aItem)
	Local $IsMaxAxe = IsMaxAxe($aItem)
	Local $IsMaxDagger = IsMaxDagger($aItem)
	Local $IsTyriaAnniSkin = IsTyriaAnniSkin($aItem)
	Local $IsCanthaAnniSkin = IsCanthaAnniSkin($aItem)
	Local $IsElonaAnniSkin = IsElonaAnniSkin($aItem)
	Local $IsEotnAnniSkin = IsEotnAnniSkin($aItem)
	Local $IsAnyCampAnniSkin = IsAnyCampAnniSkin($aItem)
 
	Switch $IsMaxDagger
	 Case True
	   Return True
	EndSwitch
 
	Switch $IsMaxAxe
	 Case True
	   Return True
	EndSwitch
 
	Switch $IsFiveE
	Case True
		Return False ; Has +5e Inherent Mod
	 EndSwitch
 
 
	Switch $IsSpecial
	Case True
	   Return False ; Is special item (Ecto, TOT, etc)
	EndSwitch
 
	Switch $Pcon
	Case True
	   Return False ; Is a Pcon
	EndSwitch
 
	Switch $Material
	Case True
	   Return False ; Is rare material
	EndSwitch
 
	Switch $IsShield
	Case True
	   Return False ; Is perfect shield
	EndSwitch
 
	Switch $IsReq8
	Case True
	   Return False ; Is req8 max
	EndSwitch
 
	Switch $IsReq7
	Case True
	   Return False ; Is req7 max (15armor)
	EndSwitch
 
	Switch $IsRune
	Case True
	   Return False
	EndSwitch
 
	Switch $RareSkin
	Case True
	   Return True
	EndSwitch

	Switch $IsTyriaAnniSkin
	Case True
	   Return False
	EndSwitch

	Switch $IsCanthaAnniSkin
	Case True
	   Return False
	EndSwitch

	Switch $IsElonaAnniSkin
	Case True
	   Return False
	EndSwitch

	Switch $IsEotnAnniSkin
	Case True
	   Return False
	EndSwitch

	Switch $IsAnyCampAnniSkin
	Case True
	   Return False
	EndSwitch
 
	Switch $IsTome
	Case True
	   Return False
	EndSwitch
 
	Switch $IsEliteTome
	Case True
	   Return False
	EndSwitch
 
	Return True
  EndFunc ;==> CanSell
#EndRegion
#Region Items
Func IsRareSkin($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
    Case 399
	   Return True ; Crystallines
    Case 344
	   Return True ; Magmas Shield
    Case 603
	   Return True ; Orrian Earth Staff
    Case 391
	   Return True ; Raven Staff
    Case 926
       Return True ; Cele Scepter All Attribs
    Case 942, 943
	   Return True ; Cele Shields (Str + Tact)
    Case 858, 776, 789
	   Return True ; Paper Fans (Divine, Soul, Energy)
    Case 905
	   Return True ; Divine Scroll (Canthan)
    Case 785
	   Return True ; Celestial Staff all attribs.
    Case 1022, 874, 875
	   Return True ; Jug - DF, SF, ES
    Case 952, 953
	   Return True ; Kappa Shields (Str + Tact)
    Case 736, 735, 778, 777, 871, 872, 741, 870, 873, 871, 872, 869, 744, 1101
	   Return True ; All rare skins from Cantha Mainland
    Case 945, 944, 940, 941, 950, 951, 1320, 1321, 789, 896, 875, 954, 955, 956, 958
	   Return True ; All rare skins from Dragon Moss
    Case 959, 960
	   Return True ; Plagueborn Shields
;~     Case 1026, 1027
;~ 	   Return True ; Plagueborn Focus (ES, DF)
    Case 341
	   Return True ; Stone Summit Shield
    Case 342
	   Return True ; Summit Warlord Shield
    Case 1985
	   Return True ; Eaglecrest Axe
    Case 2048
	   Return True ; Wingcrest Maul
    Case 2071
	   Return True ; Voltaic Spear
    Case 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973
	   Return True ; Froggy Scepters
;~     Case 1197, 1556, 1569, 1439, 1563, 1557
	Case 1197, 1556, 1569, 1439, 1563
	   Return True ; Elonian Swords (Colossal, Ornate, Tattooed, Dead, etc)
	Case 1589
		Return True ; Sea Purse Shield
	Case 1469, 1488, 1266
		Return True ; Diamong Aegis mot,com,tac
	Case 1497, 1498, 1268
		Return True ; Iridescent Aegis mot,com,tac
    Case 21439
	   Return True ; Polar Bear
    Case 1896
	   Return True ; Draconic Aegis - Str
    Case 36674
	   Return True ; Envoy Staff (Divine?)
    Case 1976
	   Return True ; Emerald Blade
    Case 1978
	   Return True ; Draconic Scythe
    Case 32823
	   Return True ; Dhuums Soul Reaper
    Case 208
	   Return True ; Ascalon War Hammer
    Case 1315
	   Return True ; Gloom Shield (Str)
    Case 1039
	   Return True ; Zodiac Shield (Str)
    Case 1037
	   Return True ; Exalted Aegis (Str)
    Case 1320
	   Return True ; Guardian Of The Hunt (Str)
    Case 956, 958
	   Return True ; Outcast Shield (Str) / (Tac)
    Case 336
	   Return True ; Shadow Shield (OS - Str)
    Case 120
	   Return True ; Sephis Axe (OS)
    Case 114
	   Return True ; Dwarven Axe (OS)
    Case 118
	   Return True ; Serpent Axe (OS)
    Case 1052
	   Return True ; Darkwing Defender (Str)
    Case 2236
	   Return True ; Enamaled Shield (Tact)
	Case 985
	   Return True ; Dragon Kamas
	Case 396
		Return True ; Brute Sword
	Case 397
		Return True ; Butterfly Sword
	Case 405
		Return True ; Falchion
	Case 400
		Return True ; Fellblade
	Case 402
		Return True ; Fiery Dragon Sword
	Case 406
		Return True ; Flamberge
	Case 407
		Return True ; Forked Sword
	Case 408
		Return True ; Gladius
	Case 412
		Return True ; Long Sword
	Case 416
		Return True ; Scimitar
	Case 417
		Return True ; Shadow Blade
	Case 418
		Return True ; Short Sword
	Case 419
		Return True ; Spatha
	Case 421
		Return True ; Wingblade
	Case 737
		Return True ; Broadsword
	Case 790
		Return True ; Celestial Sword
	Case 791
		Return True ; Crenellated Sword
	Case 739
		Return True ; Dadao Sword
	Case 740
		Return True ; Dusk Blade
	Case 795
		Return True ; Golden Phoenix Blade
	Case 793
		Return True ; Gothic Sword
	Case 1322
		Return True ; Jade Sword
	Case 741
		Return True ; Jitte
	Case 742
		Return True ; Katana
	Case 794
		Return True ; Oni Blade
	Case 796
		Return True ; Plagueborn Sword
	Case 743
		Return True ; Platinum Blade
	Case 744
		Return True ; Shinobi Blade
	Case 797
		Return True ; Sunqua Blade
	Case 792
		Return True ; Wicked Blade
	Case 1042
		Return True ; Vertebreaker
	Case 1043
		Return True ; Zodiac Sword
	EndSwitch
	Return False
EndFunc ;==> IsRareSkin 

Func IsTyriaAnniSkin($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
	Case 2017, 2018, 2019, 2020
	   Return True ; Bone Idols
	Case 2444
		Return True ; Canthan Targe
	Case 2100, 2101
		Return True ; Censor Icon
	Case 2012, 2013, 2014, 2015, 2016
		Return True ; Chirmeric Prism
	Case 2011
		Return True ; Ithas Bow
	EndSwitch
	Return False
EndFunc ;==> IsTyriaAnniSkin

Func IsCanthaAnniSkin($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
	Case 2460
	   Return True ; Dragon Fangs
	Case 2464, 2465, 2466, 2467
		Return True ; Spirit Binder
	Case 2469, 2470
		Return True ; Japan 1st Anniversary Shield
	EndSwitch
	Return False
EndFunc ;==> IsCanthaAnniSkin

Func IsElonaAnniSkin($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
	Case 2471
	   Return True ; Sunspear
	EndSwitch
	Return False
EndFunc ;==> IsElonaAnniSkin

Func IsEotnAnniSkin($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
	Case 2472
	   Return True ; Darksteel Longbow
	Case 2473
		Return True ; Glacial Blade
	Case 2474
		Return True ; Glacial Blades
	Case 2475, 2476, 2477, 2478, 2479, 2480, 2481, 2482, 2483, 2484, 2485, 2486, 2487, 2488, 2489, 2490, 2491, 2492, 2493, 2494, 2495
		Return True ; Hourglass Staff
	Case 2102, 2134, 2103
		Return True ; Etched Sword
	Case 2105, 2106
		Return True ; Arced Blade
	Case 2116, 2117
		Return True ; Granite Edge
	Case 1955, 2125, 1956
		Return True ; Stoneblade
	EndSwitch
	Return False
EndFunc ;==> IsEotnAnniSkin

Func IsAnyCampAnniSkin($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
	Case 2239
	   Return True ; Bears Sloth
	Case 2070, 2081, 2082, 2084
		Return True ; Foxs Greed
	Case 2440, 2439, 2438
		Return True ; Hogs Gluttony
	Case 2020, 2026, 2027, 2028, 2029, 2030, 2492
		Return True ; Lions Pride
	Case 2009, 2008
		Return True ; Scorpions Lust, Scorpions Bow
	Case 2451, 2452, 2453, 2454
		Return True ; Snakes Envy
	Case 2246, 2424, 2427, 2428, 2429, 2430
		Return True ; Unicorns Wrath
	Case 2010
		Return True ; Black Hawks Lust
	Case 2456, 2457, 2458, 2459
		Return True ; Dragons Envy
	Case 2431, 2432, 2433, 2434
		Return True ; Peacocks Wrath
	Case 2240
		Return True ; Rhinos Sloth
	Case 2442, 2443, 2441
		Return True ; Spiders Gluttony
	Case 2031, 2045, 2047, 2054, 2055
		Return True ; Tigers Pride
	Case 2087, 2088, 2090, 2091, 2092, 2094, 2095
		Return True ; Wolfs Greed
	Case 2133
		Return True ; Furious Bonecrusher
	Case 2435, 2436, 2437
		Return True ; Bronze Guardian
	Case 2447, 2450, 2448
		Return True ; Deaths Head
	Case 2056, 2057, 2066, 2067
		Return True ; Heavens Arch
	Case 2242, 2243, 2244, 2445
		Return True ; Quicksilver
	Case 2021, 2022, 2023, 2024, 2025
		Return True ; Storm Ember
	Case 2461
		Return True ; Omnious Aegis
	EndSwitch
	Return False
EndFunc ;==> IsAnyCampAnniSkin

Func IsPcon($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
    Case 910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682
	   Return True ; Alcohol
    Case 6376, 21809, 21810, 21813, 36683
	   Return True ; Party
    Case 21492, 21812, 22269, 22644, 22752, 28436
	   Return True ; Sweets
    Case 6370, 21488, 21489, 22191, 26784, 28433
	   Return True ; DP Removal
    Case 15837, 21490, 30648, 31020
	   Return True ; Tonic
    EndSwitch
	Return False
EndFunc ;==> IsPcon

Func IsRareMaterial($aItem)
	Local $M = GetItemInfoByPtr($aItem, "ModelID")
 
	Switch $M
	Case 937, 938, 935, 931, 932, 936, 930, 945, 923
	   Return True ; Rare Mats
	EndSwitch
	Return False
EndFunc ;==> IsRareMaterial

Func IsSpecialItem($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")
	Local $ExtraID = GetItemInfoByPtr($aItem, "ExtraID")

	Switch $ModelID
    Case 5656, 18345, 21491, 37765, 21833, 28433, 28434
	   Return True ; Special - ToT etc
    Case 22751
	   Return True ; Lockpicks
    Case 146
	   If $ExtraID = 10 Or $ExtraID = 12 Then
		  Return True ; Black & White Dye
	   Else
		  Return False
	   EndIf
    Case 24353, 24354
	   Return True ; Chalice & Rin Relics
    Case 522
	   Return True ; Dark Remains
    Case 3746, 22280
	   Return True ; Underworld & FOW Scroll
    Case 35121
	   Return True ; War supplies
    Case 36985
	   Return True ; Commendations
	Case 19186, 19187, 19188, 19189
		Return True ; Djinn Essences
    EndSwitch
	Return False
EndFunc	;==> IsSpecialItem

Func IsPerfectCaster($aItem)
	Local $ModStruct = GetModStruct($aItem)
	Local $A = GetItemAttribute($aItem)
    ; Universal mods
    Local $PlusFive = StringInStr($ModStruct, "5320823", 0, 1) ; Mod struct for +5^50
	Local $PlusFiveEnch = StringInStr($ModStruct, "500F822", 0, 1) ; Mod struct for +5wench
	Local $10Cast = StringInStr($ModStruct, "A0822", 0, 1) ; Mod struct for 10% cast
	Local $10Recharge = StringInStr($ModStruct, "AA823", 0, 1) ; Mod struct for 10% recharge
	; Ele mods
	Local $Fire20Casting = StringInStr($ModStruct, "0A141822", 0, 1) ; Mod struct for 20% fire
	Local $Fire20Recharge = StringInStr($ModStruct, "0A149823", 0, 1)
	Local $Water20Casting = StringInStr($ModStruct, "0B141822", 0, 1) ; Mod struct for 20% water
	Local $Water20Recharge = StringInStr($ModStruct, "0B149823", 0, 1)
	Local $Air20Casting = StringInStr($ModStruct, "08141822", 0, 1) ; Mod struct for 20% air
	Local $Air20Recharge = StringInStr($ModStruct, "08149823", 0, 1)
	Local $Earth20Casting = StringInStr($ModStruct, "09141822", 0, 1)
	Local $Earth20Recharge = StringInStr($ModStruct, "09149823", 0, 1)
	Local $Energy20Casting = StringInStr($ModStruct, "0C141822", 0, 1)
	Local $Energy20Recharge = StringInStr($ModStruct, "0C149823", 0, 1)
	; Monk mods
	Local $Smiting20Casting = StringInStr($ModStruct, "0E141822", 0, 1) ; Mod struct for 20% smite
	Local $Smiting20Recharge = StringInStr($ModStruct, "0E149823", 0, 1)
	Local $Divine20Casting = StringInStr($ModStruct, "10141822", 0, 1) ; Mod struct for 20% divine
	Local $Divine20Recharge = StringInStr($ModStruct, "10149823", 0, 1)
	Local $Healing20Casting = StringInStr($ModStruct, "0D141822", 0, 1) ; Mod struct for 20% healing
	Local $Healing20Recharge = StringInStr($ModStruct, "0D149823", 0, 1)
	Local $Protection20Casting = StringInStr($ModStruct, "0F141822", 0, 1) ; Mod struct for 20% protection
	Local $Protection20Recharge = StringInStr($ModStruct, "0F149823", 0, 1)
	; Rit mods
	Local $Channeling20Casting = StringInStr($ModStruct, "22141822", 0, 1) ; Mod struct for 20% channeling
	Local $Channeling20Recharge = StringInStr($ModStruct, "22149823", 0, 1)
	Local $Restoration20Casting = StringInStr($ModStruct, "21141822", 0, 1)
	Local $Restoration20Recharge = StringInStr($ModStruct, "21149823", 0, 1)
    Local $Communing20Casting = StringInStr($ModStruct, "20141822", 0, 1)
	Local $Communing20Recharge = StringInStr($ModStruct, "20149823", 0, 1)
    Local $Spawning20Casting = StringInStr($ModStruct, "24141822", 0, 1) ; Spawning - Unconfirmed
	Local $Spawning20Recharge = StringInStr($ModStruct, "24149823", 0, 1) ; Spawning - Unconfirmed
	; Mes mods
    Local $Illusion20Recharge = StringInStr($ModStruct, "01149823", 0, 1)
	Local $Illusion20Casting = StringInStr($ModStruct, "01141822", 0, 1)
	Local $Domination20Casting = StringInStr($ModStruct, "02141822", 0, 1) ; Mod struct for 20% domination
    Local $Domination20Recharge = StringInStr($ModStruct, "02149823", 0, 1) ; Mod struct for 20% domination recharge
    Local $Inspiration20Recharge = StringInStr($ModStruct, "03149823", 0, 1)
	Local $Inspiration20Casting = StringInStr($ModStruct, "03141822", 0, 1)
	; Necro mods
    Local $Death20Casting = StringInStr($ModStruct, "05141822", 0, 1) ; Mod struct for 20% death
	Local $Death20Recharge = StringInStr($ModStruct, "05149823", 0, 1)
    Local $Blood20Recharge = StringInStr($ModStruct, "04149823", 0, 1)
	Local $Blood20Casting = StringInStr($ModStruct, "04141822", 0, 1)
    Local $SoulReap20Recharge = StringInStr($ModStruct, "06149823", 0, 1)
	Local $SoulReap20Casting = StringInStr($ModStruct, "06141822", 0, 1)
    Local $Curses20Recharge = StringInStr($ModStruct, "07149823", 0, 1)
	Local $Curses20Casting = StringInStr($ModStruct, "07141822", 0, 1)

	Switch $A
    Case 1 ; Illusion
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Illusion20Casting > 0 Or $Illusion20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Illusion20Recharge > 0 Or $Illusion20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Illusion20Recharge > 0 Then
		  If $Illusion20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 2 ; Domination
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Domination20Casting > 0 Or $Domination20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Domination20Recharge > 0 Or $Domination20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Domination20Recharge > 0 Then
		  If $Domination20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 3 ; Inspiration
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Inspiration20Casting > 0 Or $Inspiration20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Inspiration20Recharge > 0 Or $Inspiration20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Inspiration20Recharge > 0 Then
		  If $Inspiration20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 4 ; Blood
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Blood20Casting > 0 Or $Blood20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Blood20Recharge > 0 Or $Blood20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Blood20Recharge > 0 Then
		  If $Blood20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 5 ; Death
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Death20Casting > 0 Or $Death20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Death20Recharge > 0 Or $Death20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Death20Recharge > 0 Then
		  If $Death20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 6 ; SoulReap - Doesnt drop?
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $SoulReap20Casting > 0 Or $SoulReap20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $SoulReap20Recharge > 0 Or $SoulReap20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $SoulReap20Recharge > 0 Then
		  If $SoulReap20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 7 ; Curses
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Curses20Casting > 0 Or $Curses20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Curses20Recharge > 0 Or $Curses20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Curses20Recharge > 0 Then
		  If $Curses20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 8 ; Air
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Air20Recharge > 0 Or $Air20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Air20Recharge > 0 Then
		  If $Air20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 9 ; Earth
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Earth20Casting > 0 Or $Earth20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Earth20Recharge > 0 Or $Earth20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Earth20Recharge > 0 Then
		  If $Earth20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
       Return False
    Case 10 ; Fire
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Fire20Casting > 0 Or $Fire20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Fire20Recharge > 0 Or $Fire20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Fire20Recharge > 0 Then
		  If $Fire20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
       Return False
    Case 11 ; Water
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Water20Casting > 0 Or $Water20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Water20Recharge > 0 Or $Water20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Water20Recharge > 0 Then
		  If $Water20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 12 ; Energy Storage
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Energy20Casting > 0 Or $Energy20Recharge > 0 Or $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Energy20Recharge > 0 Or $Energy20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Or $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
       EndIf
	   If $Energy20Recharge > 0 Then
		  If $Energy20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $10Cast > 0 Or $10Recharge > 0 Then
		  If $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 13 ; Healing
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Healing20Casting > 0 Or $Healing20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Healing20Recharge > 0 Or $Healing20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Healing20Recharge > 0 Then
		  If $Healing20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 14 ; Smiting
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Smiting20Recharge > 0 Or $Smiting20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Smiting20Recharge > 0 Then
		  If $Smiting20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 15 ; Protection
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Protection20Recharge > 0 Or $Protection20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Protection20Recharge > 0 Then
		  If $Protection20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 16 ; Divine
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Divine20Casting > 0 Or $Divine20Recharge > 0 Or $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Divine20Recharge > 0 Or $Divine20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Or $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Divine20Recharge > 0 Then
		  If $Divine20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $10Cast > 0 Or $10Recharge > 0 Then
		  If $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 32 ; Communing
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Communing20Casting > 0 Or $Communing20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Communing20Recharge > 0 Or $Communing20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Communing20Recharge > 0 Then
		  If $Communing20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
	Case 33 ; Restoration
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Restoration20Casting > 0 Or $Restoration20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Restoration20Recharge > 0 Or $Restoration20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Restoration20Recharge > 0 Then
		  If $Restoration20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 34 ; Channeling
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Channeling20Casting > 0 Or $Channeling20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Channeling20Recharge > 0 Or $Channeling20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Channeling20Recharge > 0 Then
		  If $Channeling20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 36 ; Spawning - Unconfirmed
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Spawning20Casting > 0 Or $Spawning20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Spawning20Recharge > 0 Or $Spawning20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Spawning20Recharge > 0 Then
		  If $Spawning20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    EndSwitch
    Return False
EndFunc ;==> IsPerfectCaster

Func IsPerfectStaff($aItem)
	Local $ModStruct = GetModStruct($aItem)
	Local $A = GetItemAttribute($aItem)
	; Ele mods
	Local $Fire20Casting = StringInStr($ModStruct, "0A141822", 0, 1) ; Mod struct for 20% fire
	Local $Water20Casting = StringInStr($ModStruct, "0B141822", 0, 1) ; Mod struct for 20% water
	Local $Air20Casting = StringInStr($ModStruct, "08141822", 0, 1) ; Mod struct for 20% air
	Local $Earth20Casting = StringInStr($ModStruct, "09141822", 0, 1) ; Mod Struct for 20% Earth
	Local $Energy20Casting = StringInStr($ModStruct, "0C141822", 0, 1) ; Mod Struct for 20% Energy Storage (Doesnt drop)
	; Monk mods
	Local $Smite20Casting = StringInStr($ModStruct, "0E141822", 0, 1) ; Mod struct for 20% smite
	Local $Divine20Casting = StringInStr($ModStruct, "10141822", 0, 1) ; Mod struct for 20% divine
	Local $Healing20Casting = StringInStr($ModStruct, "0D141822", 0, 1) ; Mod struct for 20% healing
	Local $Protection20Casting = StringInStr($ModStruct, "0F141822", 0, 1) ; Mod struct for 20% protection
	; Rit mods
	Local $Channeling20Casting = StringInStr($ModStruct, "22141822", 0, 1) ; Mod struct for 20% channeling
	Local $Restoration20Casting = StringInStr($ModStruct, "21141822", 0, 1) ; Mod Struct for 20% Restoration
	Local $Communing20Casting = StringInStr($ModStruct, "20141822", 0, 1) ; Mod Struct for 20% Communing
	Local $Spawning20Casting = StringInStr($ModStruct, "24141822", 0, 1) ; Mod Struct for 20% Spawning (Unconfirmed)
	; Mes mods
	Local $Illusion20Casting = StringInStr($ModStruct, "01141822", 0, 1) ; Mod struct for 20% Illusion
	Local $Domination20Casting = StringInStr($ModStruct, "02141822", 0, 1) ; Mod struct for 20% domination
	Local $Inspiration20Casting = StringInStr($ModStruct, "03141822", 0, 1) ; Mod struct for 20% Inspiration
	; Necro mods
	Local $Death20Casting = StringInStr($ModStruct, "05141822", 0, 1) ; Mod struct for 20% death
	Local $Blood20Casting = StringInStr($ModStruct, "04141822", 0, 1) ; Mod Struct for 20% Blood
    Local $SoulReap20Casting = StringInStr($ModStruct, "06141822", 0, 1) ; Mod Struct for 20% Soul Reap (Doesnt drop)
	Local $Curses20Casting = StringInStr($ModStruct, "07141822", 0, 1) ; Mod Struct for 20% Curses

	Switch $A
    Case 1 ; Illusion
	   If $Illusion20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 2 ; Domination
	   If $Domination20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 3 ; Inspiration - Doesnt Drop
	   If $Inspiration20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 4 ; Blood
	   If $Blood20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 5 ; Death
	   If $Death20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 6 ; SoulReap - Doesnt Drop
	   If $SoulReap20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 7 ; Curses
	   If $Curses20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 8 ; Air
	   If $Air20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 9 ; Earth
	   If $Earth20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 10 ; Fire
	   If $Fire20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 11 ; Water
	   If $Water20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 12 ; Energy Storage
	   If $Air20Casting > 0 Or $Earth20Casting > 0 Or $Fire20Casting > 0 Or $Water20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 13 ; Healing
	   If $Healing20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 14 ; Smiting
	   If $Smite20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 15 ; Protection
	   If $Protection20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 16 ; Divine
	   If $Healing20Casting > 0 Or $Protection20Casting > 0 Or $Divine20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 32 ; Communing
	   If $Communing20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 33 ; Restoration
	   If $Restoration20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 34 ; Channeling
	   If $Channeling20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 36 ; Spawning - Unconfirmed
	   If $Spawning20Casting > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndSwitch
	Return False
EndFunc ;==> IsPerfectStaff

Func IsPerfectShield($aItem)
    Local $ModStruct = GetModStruct($aItem)
	; Universal mods
    Local $Plus30 = StringInStr($ModStruct, "1E4823", 0, 1) ; Mod struct for +30 (shield only?)
	Local $Minus3Hex = StringInStr($ModStruct, "3009820", 0, 1) ; Mod struct for -3wHex (shield only?)
	Local $Minus2Stance = StringInStr($ModStruct, "200A820", 0, 1) ; Mod Struct for -2Stance
	Local $Minus2Ench = StringInStr($ModStruct, "2008820", 0, 1) ; Mod struct for -2Ench
	Local $Plus45Stance = StringInStr($ModStruct, "02D8823", 0, 1) ; For +45Stance
	Local $Plus45Ench = StringInStr($ModStruct, "02D6823", 0, 1) ; Mod struct for +45ench
	Local $Plus44Ench = StringInStr($ModStruct, "02C6823", 0, 1) ; For +44/+10Demons
	Local $Minus520 = StringInStr($ModStruct, "5147820", 0, 1) ; For -5(20%)
	; +1 20% Mods ~ Updated 08/10/2018 - FINISHED
	Local $PlusIllusion = StringInStr($ModStruct, "0118240", 0, 1) ; +1 Illu 20%
	Local $PlusDomination = StringInStr($ModStruct, "0218240", 0, 1) ; +1 Dom 20%
	Local $PlusInspiration = StringInStr($ModStruct, "0318240", 0, 1) ; +1 Insp 20%
	Local $PlusBlood = StringInStr($ModStruct, "0418240", 0, 1) ; +1 Blood 20%
	Local $PlusDeath = StringInStr($ModStruct, "0518240", 0, 1) ; +1 Death 20%
	Local $PlusSoulReap = StringInStr($ModStruct, "0618240", 0, 1) ; +1 SoulR 20%
	Local $PlusCurses = StringInStr($ModStruct, "0718240", 0, 1) ; +1 Curses 20%
	Local $PlusAir = StringInStr($ModStruct, "0818240", 0, 1) ; +1 Air 20%
	Local $PlusEarth = StringInStr($ModStruct, "0918240", 0, 1) ; +1 Earth 20%
    Local $PlusFire = StringInStr($ModStruct, "0A18240", 0, 1) ; +1 Fire 20%
	Local $PlusWater = StringInStr($ModStruct, "0B18240", 0, 1) ; +1 Water 20%
	Local $PlusHealing = StringInStr($ModStruct, "0D18240", 0, 1) ; +1 Heal 20%
	Local $PlusSmite = StringInStr($ModStruct, "0E18240", 0, 1) ; +1 Smite 20%
	Local $PlusProt = StringInStr($ModStruct, "0F18240", 0, 1) ; +1 Prot 20%
	Local $PlusDivine = StringInStr($ModStruct, "1018240", 0, 1) ; +1 Divine 20%
	; +10vsMonster Mods
	Local $PlusDemons = StringInStr($ModStruct, "A0848210", 0, 1) ; +10vs Demons
	Local $PlusDragons = StringInStr($ModStruct, "A0948210", 0, 1) ; +10vs Dragons
	Local $PlusPlants = StringInStr($ModStruct, "A0348210", 0, 1) ; +10vs Plants
	Local $PlusUndead = StringInStr($ModStruct, "A0048210", 0, 1) ; +10vs Undead
	Local $PlusTengu = StringInStr($ModStruct, "A0748210", 0, 1) ; +10vs Tengu
    ; New +10vsMonster Mods 07/10/2018 - Thanks to Savsuds
    Local $PlusCharr = StringInStr($ModStruct, "0A014821", 0 ,1) ; +10vs Charr
    Local $PlusTrolls = StringInStr($ModStruct, "0A024821", 0 ,1) ; +10vs Trolls
    Local $PlusSkeletons = StringInStr($ModStruct, "0A044821", 0 ,1) ; +10vs Skeletons
    Local $PlusGiants = StringInStr($ModStruct, "0A054821", 0 ,1) ; +10vs Giants
    Local $PlusDwarves = StringInStr($ModStruct, "0A064821", 0 ,1) ; +10vs Dwarves
    Local $PlusDragons = StringInStr($ModStruct, "0A094821", 0 ,1) ; +10vs Dragons
    Local $PlusOgres = StringInStr($ModStruct, "0A0A4821", 0 ,1) ; +10vs Ogres
	; +10vs Dmg
	Local $PlusPiercing = StringInStr($ModStruct, "A0118210", 0, 1) ; +10vs Piercing
	Local $PlusLightning = StringInStr($ModStruct, "A0418210", 0, 1) ; +10vs Lightning
	Local $PlusVsEarth = StringInStr($ModStruct, "A0B18210", 0, 1) ; +10vs Earth
	Local $PlusCold = StringInStr($ModStruct, "A0318210", 0, 1) ; +10 vs Cold
	Local $PlusSlashing = StringInStr($ModStruct, "A0218210", 0, 1) ; +10vs Slashing
	Local $PlusVsFire = StringInStr($ModStruct, "A0518210", 0, 1) ; +10vs Fire
	; New +10vs Dmg 08/10/2018
	Local $PlusBlunt = StringInStr($ModStruct, "A0018210", 0, 1) ; +10vs Blunt

    If $Plus30 > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
	      Return True
	   ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
		  Return True
	   ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
		  Return True
	   ElseIf $Minus2Stance > 0 Or $Minus2Ench > 0 Or $Minus520 > 0 Or $Minus3Hex > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndIf
    If $Plus45Ench > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
	      Return True
	   ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
		  Return True
	   ElseIf $Minus2Ench > 0 Then
		  Return True
	   ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndIf
	If $Minus2Ench > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
		  Return True
	   ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
		  Return True
	   EndIf
	EndIf
    If $Plus44Ench > 0 Then
	   If $PlusDemons > 0 Then
	      Return True
	   EndIf
	EndIf
    If $Plus45Stance > 0 Then
	   If $Minus2Stance > 0 Then
	      Return True
	   EndIf
	EndIf
	Return False
EndFunc ;==> IsPerfectShield

Func IsRareRune($aItem)
    Local $ModStruct = GetModStruct($aItem)
	Local $SupVigor = StringInStr($ModStruct, "C202EA27", 0, 1) ; Mod struct for Sup vigor rune
	Local $minorStrength = StringInStr($ModStruct, "0111E821", 0, 1) ; minor Strength
	Local $minorTactics = StringInStr($ModStruct, "0115E821", 0, 1) ; minor Tactics
	Local $minorExpertise = StringInStr($ModStruct, "0117E821", 0, 1) ; minor Expertise
	Local $minorMarksman = StringInStr($ModStruct, "0119E821", 0, 1) ; minor Marksman
	Local $minorHealing = StringInStr($ModStruct, "010DE821", 0, 1) ; minor Healing
	Local $minorProt = StringInStr($ModStruct, "010FE821", 0, 1) ; minor Prot
	Local $minorDivine = StringInStr($ModStruct, "0110E821", 0, 1) ; minor Divine
	Local $minorSoul = StringInStr($ModStruct, "0106E821", 0, 1) ; minor Soul
	Local $minorFastcast = StringInStr($ModStruct, "0100E821", 0, 1) ; minor Fastcast
	Local $minorInsp = StringInStr($ModStruct, "0103E821", 0, 1) ; minor Insp
	Local $minorEnergy = StringInStr($ModStruct, "010CE821", 0, 1) ; minor Energy
	Local $minorSpawn = StringInStr($ModStruct, "0124E821", 0, 1) ; minor Spawn
	Local $minorScythe = StringInStr($ModStruct, "0129E821", 0, 1) ; minor Scythe
	Local $minorMystic = StringInStr($ModStruct, "012CE821", 0, 1) ; minor Mystic
	Local $minorVigor = StringInStr($ModStruct, "C202E827", 0, 1) ; minor Vigor
	Local $minorVitae = StringInStr($ModStruct, "12020824", 0, 1) ; minor Vitae

	Local $majorFast = StringInStr($ModStruct, "0200E821", 0, 1) ; major Fastcast
	Local $majorVigor = StringInStr($ModStruct, "C202E927", 0, 1) ; major Vigor

	Local $supSmite = StringInStr($ModStruct, "030EE821", 0, 1) ; superior Smite
	Local $supDeath = StringInStr($ModStruct, "0305E821", 0, 1) ; superior Death
	Local $supDom = StringInStr($ModStruct, "0302E821", 0, 1) ; superior Dom
	Local $supAir = StringInStr($ModStruct, "0308E821", 0, 1) ; superior Air
	Local $supChannel = StringInStr($ModStruct, "0322E821", 0, 1) ; superior Channel
	Local $supCommu = StringInStr($ModStruct, "0320E821", 0, 1) ; superior Commu

	If $minorStrength > 0 Or $minorTactics > 0 Or $minorExpertise > 0 Or $minorMarksman > 0 Or $minorHealing > 0 Or $minorProt > 0 Or $minorDivine > 0 Then 
	   	Return True
	ElseIf $minorSoul > 0 Or $minorFastcast > 0 Or $minorInsp > 0 Or $minorEnergy > 0 Or $minorSpawn > 0 Or $minorScythe > 0 Or $minorMystic > 0 Then
		Return True
	ElseIf $minorVigor > 0 Or $minorVitae > 0 Or $majorFast > 0 Or $majorVigor > 0 Or $supSmite > 0 Or $supDeath > 0 Or $supDom > 0 Then
		Return True
	ElseIf $supAir > 0 Or $supChannel > 0 Or $supCommu > 0 Or $SupVigor > 0 Then
		Return True
	Else
	   Return False
	EndIf
EndFunc ;==> IsRareRune

Func IsSellableRune($aItem)
    Local $ModStruct = GetModStruct($aItem)
	Local $SupVigor = StringInStr($ModStruct, "C202EA27", 0, 1) ; Mod struct for Sup vigor rune
	Local $minorStrength = StringInStr($ModStruct, "0111E821", 0, 1) ; minor Strength
	Local $minorTactics = StringInStr($ModStruct, "0115E821", 0, 1) ; minor Tactics
	Local $minorExpertise = StringInStr($ModStruct, "0117E821", 0, 1) ; minor Expertise
	Local $minorMarksman = StringInStr($ModStruct, "0119E821", 0, 1) ; minor Marksman
	Local $minorHealing = StringInStr($ModStruct, "010DE821", 0, 1) ; minor Healing
	Local $minorProt = StringInStr($ModStruct, "010FE821", 0, 1) ; minor Prot
	Local $minorDivine = StringInStr($ModStruct, "0110E821", 0, 1) ; minor Divine
	Local $minorSoul = StringInStr($ModStruct, "0106E821", 0, 1) ; minor Soul
	Local $minorFastcast = StringInStr($ModStruct, "0100E821", 0, 1) ; minor Fastcast
	Local $minorInsp = StringInStr($ModStruct, "0103E821", 0, 1) ; minor Insp
	Local $minorEnergy = StringInStr($ModStruct, "010CE821", 0, 1) ; minor Energy
	Local $minorSpawn = StringInStr($ModStruct, "0124E821", 0, 1) ; minor Spawn
	Local $minorScythe = StringInStr($ModStruct, "0129E821", 0, 1) ; minor Scythe
	Local $minorMystic = StringInStr($ModStruct, "012CE821", 0, 1) ; minor Mystic
	Local $minorVigor = StringInStr($ModStruct, "C202E827", 0, 1) ; minor Vigor
	Local $minorVitae = StringInStr($ModStruct, "12020824", 0, 1) ; minor Vitae

	Local $majorFast = StringInStr($ModStruct, "0200E821", 0, 1) ; major Fastcast
	Local $majorVigor = StringInStr($ModStruct, "C202E927", 0, 1) ; major Vigor

	Local $supSmite = StringInStr($ModStruct, "030EE821", 0, 1) ; superior Smite
	Local $supDeath = StringInStr($ModStruct, "0305E821", 0, 1) ; superior Death
	Local $supDom = StringInStr($ModStruct, "0302E821", 0, 1) ; superior Dom
	Local $supAir = StringInStr($ModStruct, "0308E821", 0, 1) ; superior Air
	Local $supChannel = StringInStr($ModStruct, "0322E821", 0, 1) ; superior Channel
	Local $supCommu = StringInStr($ModStruct, "0320E821", 0, 1) ; superior Commu

	If $minorStrength > 0 Or $minorTactics > 0 Or $minorExpertise > 0 Or $minorMarksman > 0 Or $minorHealing > 0 Or $minorProt > 0 Or $minorDivine > 0 Then 
		Return True
 	ElseIf $minorSoul > 0 Or $minorFastcast > 0 Or $minorInsp > 0 Or $minorEnergy > 0 Or $minorSpawn > 0 Or $minorScythe > 0 Or $minorMystic > 0 Then
	 	Return True
 	ElseIf $minorVigor > 0 Or $minorVitae > 0 Or $majorFast > 0 Or $majorVigor > 0 Or $supSmite > 0 Or $supDeath > 0 Or $supDom > 0 Then
	 	Return True
	ElseIf $supAir > 0 Or $supChannel > 0 Or $supCommu > 0 Or $SupVigor > 0 Then
		Return True
	Else
	   Return False
	EndIf
EndFunc ;==> IsSellableRune

Func IsSupVigor($aItem)
	Local $ModStruct = GetModStruct($aItem)
	Local $SupVigor = StringInStr($ModStruct, "C202EA27", 0, 1) ; Mod struct for Sup vigor rune

	If $SupVigor > 0 Then
	   Return True
	Else
	   Return False
	EndIf
EndFunc ;==> IsSupVigor


Func IsRareInsignia($aItem)
    Local $ModStruct = GetModStruct($aItem)
	Local $Sentinel = StringInStr($ModStruct, "FB010824", 0, 1) ; Sentinel insig
	Local $Tormentor = StringInStr($ModStruct, "EC010824", 0, 1) ; Tormentor insig
	Local $WindWalker = StringInStr($ModStruct, "02020824", 0, 1) ; Windwalker insig
	Local $Prodigy = StringInStr($ModStruct, "E3010824", 0, 1) ; Prodigy insig
	Local $Shamans = StringInStr($ModStruct, "04020824", 0, 1) ; Shamans insig
	Local $Nightstalker = StringInStr($ModStruct, "E1010824", 0, 1) ; Nightstalker insig
	Local $Centurions = StringInStr($ModStruct, "07020824", 0, 1) ; Centurions insig
	Local $Blessed = StringInStr($ModStruct, "E9010824", 0, 1) ; Blessed insig

	If $Sentinel > 0 Or $Tormentor > 0 Or $WindWalker > 0 Or $Prodigy > 0 Or $Shamans > 0 Or $Nightstalker > 0 Or $Centurions > 0 Or $Blessed > 0 Then
	   Return True
	Else
	   Return False
	EndIf
EndFunc ;==> IsRareInsignia

Func IsSellableInsignia($aItem)
    Local $ModStruct = GetModStruct($aItem)
	Local $Sentinel = StringInStr($ModStruct, "FB010824", 0, 1) ; Sentinel insig
	Local $Tormentor = StringInStr($ModStruct, "EC010824", 0, 1) ; Tormentor insig
	Local $WindWalker = StringInStr($ModStruct, "02020824", 0, 1) ; Windwalker insig
	Local $Prodigy = StringInStr($ModStruct, "E3010824", 0, 1) ; Prodigy insig
	Local $Shamans = StringInStr($ModStruct, "04020824", 0, 1) ; Shamans insig
	Local $Nightstalker = StringInStr($ModStruct, "E1010824", 0, 1) ; Nightstalker insig
	Local $Centurions = StringInStr($ModStruct, "07020824", 0, 1) ; Centurions insig
	Local $Blessed = StringInStr($ModStruct, "E9010824", 0, 1) ; Blessed insig

	If $Sentinel > 0 Or $Tormentor > 0 Or $WindWalker > 0 Or $Prodigy > 0 Or $Shamans > 0 Or $Nightstalker > 0 Or $Centurions > 0 Or $Blessed > 0 Then
	   Return True
	Else
	   Return False
	EndIf
EndFunc ;==> IsSellableInsignia

Func IsReq8Max($aItem)
	Local $Type = GetItemInfoByPtr($aItem, "ItemType")
	Local $Rarity = GetItemInfoByPtr($aItem, "Rarity")
	Local $MaxDmgOffHand = GetItemMaxReq8($aItem)
	Local $MaxDmgShield = GetItemMaxReq8($aItem)
	Local $MaxDmgSword = GetItemMaxReq8($aItem)

	Switch $Rarity
    Case 2624 ;~ Gold
       Switch $Type
	   Case 12 ;~ Offhand
		  If $MaxDmgOffHand = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 24 ;~ Shield
		  If $MaxDmgShield = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 27 ;~ Sword
		  If $MaxDmgSword = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   EndSwitch
    Case 2623 ;~ Purple?
	   Switch $Type
	   Case 12 ;~ Offhand
		  If $MaxDmgOffHand = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 24 ;~ Shield
		  If $MaxDmgShield = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 27 ;~ Sword
		  If $MaxDmgSword = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   EndSwitch
    Case 2626 ;~ Blue?
	   Switch $Type
	   Case 12 ;~ Offhand
		  If $MaxDmgOffHand = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 24 ;~ Shield
		  If $MaxDmgShield = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 27 ;~ Sword
		  If $MaxDmgSword = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   EndSwitch
	EndSwitch
	Return False
EndFunc ;==> IsReq8Max

Func IsReq7Max($aItem)
	Local $Type = GetItemInfoByPtr($aItem, "ItemType")
	Local $Rarity = GetItemInfoByPtr($aItem, "Rarity")
	Local $MaxDmgOffHand = GetItemMaxReq7($aItem)
	Local $MaxDmgShield = GetItemMaxReq7($aItem)
	Local $MaxDmgSword = GetItemMaxReq7($aItem)

	Switch $Rarity
    Case 2624 ;~ Gold
       Switch $Type
	   Case 12 ;~ Offhand
		  If $MaxDmgOffHand = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 24 ;~ Shield
		  If $MaxDmgShield = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 27 ;~ Sword
		  If $MaxDmgSword = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   EndSwitch
    Case 2623 ;~ Purple?
	   Switch $Type
	   Case 12 ;~ Offhand
		  If $MaxDmgOffHand = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 24 ;~ Shield
		  If $MaxDmgShield = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 27 ;~ Sword
		  If $MaxDmgSword = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   EndSwitch
    Case 2626 ;~ Blue?
	   Switch $Type
	   Case 12 ;~ Offhand
		  If $MaxDmgOffHand = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 24 ;~ Shield
		  If $MaxDmgShield = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   Case 27 ;~ Sword
		  If $MaxDmgSword = True Then
			 Return True
		  Else
			 Return False
		  EndIf
	   EndSwitch
	EndSwitch
	Return False
EndFunc ;==> IsReq7Max

Func GetItemMaxReq8($aItem)
	Local $Type = GetItemInfoByPtr($aItem, "ItemType")
	Local $Dmg = GetItemMaxDmg($aItem)
	Local $Req = GetItemReq($aItem)

	Switch $Type
    Case 12 ;~ Offhand
	   If $Dmg == 12 And $Req == 8 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 24 ;~ Shield
	   If $Dmg == 16 And $Req == 8 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 27 ;~ Sword
	   If $Dmg == 22 And $Req == 8 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndSwitch
EndFunc ;==> GetItemMaxReq8

Func GetItemMaxReq7($aItem)
	Local $Type = GetItemInfoByPtr($aItem, "ItemType")
	Local $Dmg = GetItemMaxDmg($aItem)
	Local $Req = GetItemReq($aItem)

	Switch $Type
    Case 12 ;~ Offhand
	   If $Dmg == 11 And $Req == 7 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 24 ;~ Shield
	   If $Dmg == 15 And $Req == 7 Then
		  Return True
	   Else
		  Return False
	   EndIf
    Case 27 ;~ Sword
	   If $Dmg == 21 And $Req == 7 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndSwitch
EndFunc ;==> GetItemMaxReq7

Func IsRegularTome($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
    Case 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805
	   Return True
	EndSwitch
	Return False
EndFunc ;==> IsRegularTome

Func IsEliteTome($aItem)
	Local $ModelID = GetItemInfoByPtr($aItem, "ModelID")

	Switch $ModelID
    Case 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795
	   Return True ; All Elite Tomes
	EndSwitch
	Return False
EndFunc ;==> IsEliteTome

Func IsFiveE($aItem)
	Local $ModStruct = GetModStruct($aItem)
	Local $t = GetItemInfoByPtr($aItem, "ItemType")
	If (IsIHaveThePower($ModStruct) and $t = 2) Then Return True	; (Nur für Äxte)
EndFunc	;==> IsFiveE

Func IsIHaveThePower($ModStruct)
	Local $EnergyAlways5 = StringInStr($ModStruct, "0500D822", 0 ,1) ; Energy +5
	If $EnergyAlways5 > 0 Then Return True
EndFunc ;==> IsIHaveThePower

Func IsMaxAxe($aItem)
	Local $Type = GetItemInfoByPtr($aItem, "ItemType")
	Local $Dmg = GetItemMaxDmg($aItem)
	Local $Req = GetItemReq($aItem)

	If $Type == 2 and $Dmg == 28 and $Req == 9 Then
		Return True
	Else
		Return False
	EndIf
EndFunc ;==> IsMaxAxe

Func IsMaxDagger($aItem)
	Local $Type = GetItemInfoByPtr($aItem, "ItemType")
	Local $Dmg = GetItemMaxDmg($aItem)
	Local $Req = GetItemReq($aItem)

	If $Type == 32 and $Dmg == 17 and $Req == 9 Then
		Return True
	Else
		Return False
	EndIf
EndFunc ;==> IsMaxDagger

#EndRegion
;~ Description: Returns max Kurzick faction.
Func GetMaxKurzickFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7B8]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxKurzickFaction

;~ Description: Returns current Luxon faction.
Func GetLuxonFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x758]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuxonFaction

;~ Description: Returns max Luxon faction.
Func GetMaxLuxonFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7BC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxLuxonFaction

;~ Description: Returns current Balthazar faction.
Func GetBalthazarFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x798]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetBalthazarFaction

;~ Description: Returns max Balthazar faction.
Func GetMaxBalthazarFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxBalthazarFaction

;~ Description: Returns current Imperial faction.
Func GetImperialFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x76C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetImperialFaction

;~ Description: Returns max Imperial faction.
Func GetMaxImperialFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxImperialFaction
#EndRegion Faction

#To be organized
; Utility function: Min of two values
Func Min($a, $b)
    If $a < $b Then
        Return $a
    Else
        Return $b
    EndIf
EndFunc

; Function to get a random game joke
Func GetRandomGameJoke()
    Local $jokes[] = [ _
        "Why did the gamer go broke? Because he was spending too much time on his console! 😄", _
        "What do you call a gamer who's always late? A lag-ger! 🎮", _
        "Why don't skeletons fight each other? They don't have the guts! 💀", _
        "What's a gamer's favorite type of music? Heavy metal! 🤘", _
        "Why did the programmer quit his job? Because he didn't get arrays! 😂", _
        "What do you call a bear with no teeth? A gummy bear! 🐻", _
        "Why did the scarecrow win an award? Because he was outstanding in his field! 🌾", _
        "What do you call a fake noodle? An impasta! 🍝", _
        "Why don't eggs tell jokes? They'd crack each other up! 🥚", _
        "What do you call a can opener that doesn't work? A can't opener! 🥫", _
        "Why did the math book look so sad? Because it had too many problems! 📚", _
        "What do you call a bear with no ears? B! 🐻", _
        "Why did the cookie go to the doctor? Because it was feeling crumbly! 🍪", _
        "What do you call a fish wearing a bowtie? So-fish-ticated! 🐟", _
        "Why don't scientists trust atoms? Because they make up everything! ⚛️", _
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks! 🦖", _
        "Why did the golfer bring two pairs of pants? In case he got a hole in one! ⛳", _
        "What do you call a sleeping bull? A bulldozer! 🐂", _
        "Why did the scarecrow win an award? Because he was outstanding in his field! 🌾", _
        "What do you call a bear with no teeth? A gummy bear! 🐻", _
        "Why don't eggs tell jokes? They'd crack each other up! 🥚", _
        "What do you call a fake noodle? An impasta! 🍝", _
        "Why did the math book look so sad? Because it had too many problems! 📚", _
        "What do you call a can opener that doesn't work? A can't opener! 🥫", _
        "Why did the cookie go to the doctor? Because it was feeling crumbly! 🍪", _
        "What do you call a fish wearing a bowtie? So-fish-ticated! 🐟", _
        "Why don't scientists trust atoms? Because they make up everything! ⚛️", _
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks! 🦖", _
        "Why did the golfer bring two pairs of pants? In case he got a hole in one! ⛳", _
        "What do you call a sleeping bull? A bulldozer! 🐂", _
        "Why did the scarecrow win an award? Because he was outstanding in his field! 🌾", _
        "What do you call a bear with no teeth? A gummy bear! 🐻", _
        "Why don't eggs tell jokes? They'd crack each other up! 🥚", _
        "What do you call a fake noodle? An impasta! 🍝", _
        "Why did the math book look so sad? Because it had too many problems! 📚", _
        "What do you call a can opener that doesn't work? A can't opener! 🥫", _
        "Why did the cookie go to the doctor? Because it was feeling crumbly! 🍪", _
        "What do you call a fish wearing a bowtie? So-fish-ticated! 🐟", _
        "Why don't scientists trust atoms? Because they make up everything! ⚛️", _
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks! 🦖", _
        "Why did the golfer bring two pairs of pants? In case he got a hole in one! ⛳", _
        "What do you call a sleeping bull? A bulldozer! 🐂" _
    ]
    
    Local $randomIndex = Random(0, UBound($jokes) - 1, 1)
    Return $jokes[$randomIndex]
EndFunc

;~ Description: Move to coordinates and kill all enemies in range
;~ Parameters: $aX, $aY = Target coordinates, $aDescription = Description for logging, $aRange = Attack range (default: $RANGE_SPELLCAST)
Func MoveToKill($aX, $aY, $aDescription = "", $aRange = $RANGE_SPELLCAST)
    Local $lMe = GetAgentPtr(-2)
    Local $currentTargetID = 0
    Local $lInCombat = False
    Local $lDestinationReached = False
    Local $combatCheckRange = $aRange
    
    If $aDescription <> "" Then
        Out("Moving to kill: " & $aDescription & " at (" & $aX & ", " & $aY & ")")
    Else
        Out("Moving to kill enemies at (" & $aX & ", " & $aY & ")")
    EndIf

    While Not $lDestinationReached
        If GetIsDead($lMe) Then
            Out("Player is dead, stopping combat")
            OutExtra("Character died at (" & X(-2) & ", " & Y(-2) & ") while moving to (" & $aX & ", " & $aY & ")")
            Return False
        EndIf
        
        ; Check for enemies in range
        Local $lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $combatCheckRange)
        If $lEnemyCount > 0 Then
            If Not $lInCombat Then
                Out("Found " & $lEnemyCount & " enemies, engaging combat!")
                $lInCombat = True
            EndIf
            ; Combat loop
            Do
                If GetIsDead($lMe) Then
                    Out("Player is dead during combat")
                    OutExtra("Character died at (" & X(-2) & ", " & Y(-2) & ") while moving to (" & $aX & ", " & $aY & ")")
                    Return False
                EndIf
                $lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $combatCheckRange)
                If $lEnemyCount = 0 Then
                    Out("Combat complete, resuming movement to target")
                    $lInCombat = False
                    ExitLoop
                EndIf
                Local $lTarget = GetNearestEnemyPtrToAgent(-2)
                If $lTarget <> 0 And Not GetIsDead($lTarget) Then
                    Local $targetID = ID($lTarget)
                    If $targetID <> $currentTargetID Then
                        ChangeTarget($lTarget)
                        Attack($lTarget, True)
                        $currentTargetID = $targetID
                        Out("Switched to new target: " & GetPlayerName($lTarget))
                    EndIf
                    If GetDistance($lTarget, -2) <= $RANGE_SPELLCAST Then
                        UseSkillsWithPriorityAndCustomOrder($lTarget)
                    EndIf
                EndIf
                UpdateExtraStatisticsDisplay()
                Sleep(10)
            Until False
            PickUpLoot()
            Out("Checking for dead party members after combat...")
            CheckAndResurrectPartyMembers()
        Else
            ; Move directly to destination
            Local $curX = X(-2)
            Local $curY = Y(-2)
            Local $dist = GetDistanceToXY($aX, $aY, -2)
            If $dist < 100 Then
                $lDestinationReached = True
                ExitLoop
            EndIf
            MoveTo($aX, $aY, 50)
            UpdateExtraStatisticsDisplay()
            Sleep(10)
        EndIf
    WEnd
    Out("Reached destination at (" & $aX & ", " & $aY & ")")
    Out("🎮 " & GetRandomGameJoke())
    $Stat_LuxonFaction = GetLuxonFaction()
    $Stat_LuxonFactionMax = GetMaxLuxonFaction()
    $Stat_CurrentGold = GetGoldCharacter()
    UpdateStatisticsDisplay()
    Return True
EndFunc

; Function to build skill name array from constants
Func BuildSkillNameArray()
    Out("Building comprehensive skill name array from constants...")
    
    ; Clear the array first
    For $i = 0 To UBound($SkillNameArray) - 1
        $SkillNameArray[$i] = ""
    Next
    
    Out("Skill name array built with " & UBound($SkillNameArray) & " entries")
EndFunc

; Function to get skill name from ID using the array
Func GetSkillNameFromArray($skillID)
    If $skillID >= 0 And $skillID < UBound($SkillNameArray) Then
        If $SkillNameArray[$skillID] <> "" Then
            Return $SkillNameArray[$skillID]
        EndIf
    EndIf
    Return "Unknown Skill (" & $skillID & ")"
EndFunc

Func UpdateSkillbarDisplay()
    If Not $BotInitialized Then
        Out("Bot not initialized, showing placeholder skill names")
        ; Show placeholder names when bot is not initialized
        For $i = 0 To 7
            GUICtrlSetData($SkillNames[$i], "Slot " & ($i + 1))
        Next
        Return
    EndIf
    
    Out("Updating skillbar display...")
    For $i = 0 To 7
        Local $skillID = GetSkillbarSkillID($i + 1)
        Local $skillName = GetSkillNameFromArray($skillID)
        
        ; Show skill name from array
        GUICtrlSetData($SkillNames[$i], $skillName)
        
        ; Debug output to help identify issues
        Out("Skill " & ($i + 1) & ": ID=" & $skillID & ", Name='" & $skillName & "'")
    Next
    Out("Skillbar updated successfully")
EndFunc

; Function to initialize skill names when GUI is first created
Func InitializeSkillNames()
    Out("Initializing skill names display...")
    
    ; Set placeholder names
    For $i = 0 To 7
        GUICtrlSetData($SkillNames[$i], "Slot " & ($i + 1))
    Next
    Out("Skill names initialized with placeholders")
EndFunc

Func UpdateCustomFightingList()
    ; Clear the list
    GUICtrlSetData($GUICustomFightingList, "")
    
    ; Add skills in custom order (with safety check)
    If $CustomFightingCount > 0 Then
        For $i = 0 To $CustomFightingCount - 1
            Local $skillSlot = $CustomFightingOrder[$i]
            Local $skillID = GetSkillbarSkillID($skillSlot)
            Local $skillName = GetSkillNameFromArray($skillID)
            Local $listItem = $skillSlot & ": " & $skillName
            GUICtrlSetData($GUICustomFightingList, $listItem)
        Next
    EndIf
EndFunc

Func UseSkillsWithPriorityAndCustomOrder($lTarget)
    ; If custom fighting is enabled, use custom order
    If $CustomFightingEnabled And $CustomFightingCount > 0 Then
        UseCustomFightingOrder($lTarget)
    Else
        ; Use normal priority-based skill usage
        UsePrioritySkills($lTarget)
    EndIf
EndFunc

Func UseCustomFightingOrder($lTarget)
    ; Check if we have any skills in custom order
    If $CustomFightingCount <= 0 Then
        ; No skills available, just return (main loop handles attacking)
        Return
    EndIf
    ; Use skills in the custom fighting order
    Local $skillSlot = $CustomFightingOrder[$CurrentCustomSkillIndex]
    Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$skillSlot - 1]) = $GUI_CHECKED
    Local $skillRecharged = IsRecharged($skillSlot)
    Local $skillEnergy = GetEnergy(-2)
    Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($skillSlot))
    If $skillEnabled And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
        ; Use the skill
        UseSkillEx($skillSlot, $lTarget, 3000, false)
        HighlightSkillLabel($skillSlot)
        RndSleep(200)
        $CurrentCustomSkillIndex += 1
        If $CurrentCustomSkillIndex >= $CustomFightingCount Then
            $CurrentCustomSkillIndex = 0 ; Reset to beginning
        EndIf
    Else
        $CurrentCustomSkillIndex += 1
        If $CurrentCustomSkillIndex >= $CustomFightingCount Then
            $CurrentCustomSkillIndex = 0 ; Reset to beginning
        EndIf
    EndIf
    ; Main combat loop handles attacking, no need to call Attack here
EndFunc

Func UsePrioritySkills($lTarget)
    ; First, try to use priority skills
    For $i = 1 To 8
        Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillPriority = GUICtrlRead($SkillPriorityCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillRecharged = IsRecharged($i)
        Local $skillEnergy = GetEnergy(-2)
        Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($i))
        If $skillPriority And $skillEnabled And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
            UseSkillEx($i, $lTarget, 3000, True)
            HighlightSkillLabel($i)
            RndSleep(200)
            Return ; Exit after using one priority skill
        EndIf
    Next
    ; If no priority skills available, use normal skills
    For $i = 1 To 8
        Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillPriority = GUICtrlRead($SkillPriorityCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillRecharged = IsRecharged($i)
        Local $skillEnergy = GetEnergy(-2)
        Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($i))
        If $skillEnabled And Not $skillPriority And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
            UseSkillEx($i, $lTarget, 3000, True)
            HighlightSkillLabel($i)
            RndSleep(200)
            Return ; Exit after using one skill
        EndIf
    Next
    ; If no skills are available, main combat loop handles attacking
EndFunc

; Function to check for dead party members and wait for them to be resurrected
Func CheckAndResurrectPartyMembers()
	Local $deadMembers = 0
	Local $deadPartyMembers[1] = [0] ; Array to store dead member agent IDs
	
	; Check all party members for dead status
	Local $partySize = GetPartySize()
	
	; Check heroes (party members 1 to party size)
	For $i = 1 To $partySize
		Local $memberAgentID = 0
		
		 ; Get agent ID for this party member
		If $i = 1 Then
			; Player character
			$memberAgentID = GetMyID()
		Else
			; Hero (party member number - 1 for hero array)
			$memberAgentID = GetMyPartyHeroInfo($i - 1, "AgentID")
		EndIf
		
		; Check if this member is dead
		If $memberAgentID <> 0 And GetIsDead($memberAgentID) Then
			$deadMembers += 1
			ReDim $deadPartyMembers[$deadMembers + 1]
			$deadPartyMembers[$deadMembers] = $memberAgentID
			
			Local $memberName = "Unknown"
			If $i = 1 Then
				$memberName = GetPlayerName($memberAgentID)
			Else
				; For heroes, we can get the hero name if needed
				$memberName = "Hero " & ($i - 1)
			EndIf
			
			Out("Found dead party member: " & $memberName & " (Agent ID: " & $memberAgentID & ")")
		EndIf
	Next
	
	; If we have dead members, wait for them to be resurrected
	If $deadMembers > 0 Then
		Out("Found " & $deadMembers & " dead party member(s), waiting for resurrection by other party members...")
		OutExtra("Team is dead at (" & X(-2) & ", " & Y(-2) & ") waiting for resurrection. Last move target: (" & $lastMoveToX & ", " & $lastMoveToY & ")")
		
		; Wait for all dead members to be resurrected
		Local $resurrectionTimer = TimerInit()
		Local $allResurrected = False
		
		Do
			; Check if all members are now alive
			$allResurrected = True
			For $i = 1 To $deadMembers
				If GetIsDead($deadPartyMembers[$i]) Then
					$allResurrected = False
					ExitLoop
				EndIf
			Next
			
			; If all are resurrected, break the loop
			If $allResurrected Then
				Out("All party members have been resurrected!")
				ExitLoop
			EndIf
			
			; Wait a bit before checking again
			RndSleep(2000)
			
			; Check for timeout (2 minutes)
			If TimerDiff($resurrectionTimer) > 120000 Then
				Out("Warning: Timeout reached waiting for resurrection. Continuing anyway...")
				ExitLoop
			EndIf
			
		Until False
		
		; Final status report
		Local $stillDead = 0
		For $i = 1 To $deadMembers
			If GetIsDead($deadPartyMembers[$i]) Then
				$stillDead += 1
			EndIf
		Next
		
		If $stillDead > 0 Then
			Out("Warning: " & $stillDead & " party member(s) still dead after waiting period")
		Else
			Out("All party members successfully resurrected by other party members!")
		EndIf
		
		Return True
	EndIf
	
	Return True ; No dead members found
EndFunc

Func UpdateStatisticsDisplay()
    GUICtrlSetData($StatDeathsLabel, "Deaths: " & $Stat_Deaths)
    GUICtrlSetData($StatTotalRunsLabel, "Total Runs: " & $Stat_TotalRuns)
    GUICtrlSetData($StatTotalRunTimeLabel, "Total Run Time: " & $Stat_TotalRunTime & "s")
    GUICtrlSetData($StatAvgRunTimeLabel, "Avg Run Time: " & $Stat_AvgRunTime & "s")
    GUICtrlSetData($StatGoldsLabel, "Golds picked up: " & $Stat_Golds)
    GUICtrlSetData($StatPurplesLabel, "Purples picked up: " & $Stat_Purples)
    GUICtrlSetData($StatBluesLabel, "Blues picked up: " & $Stat_Blues)
    GUICtrlSetData($StatWhitesLabel, "Whites picked up: " & $Stat_Whites)
    GUICtrlSetData($StatLuxonFactionLabel, "Luxon Faction: " & $Stat_LuxonFaction & " / " & $Stat_LuxonFactionMax)
    GUICtrlSetData($StatLuxonDonatedLabel, "Luxon Donated: " & $Stat_LuxonDonated)
    GUICtrlSetData($StatCurrentGoldLabel, "Current Gold: " & $Stat_CurrentGold)
    GUICtrlSetData($StatGoldPickedUpLabel, "Gold Picked Up: " & $Stat_GoldPickedUp)
    UpdateExtraStatisticsDisplay()
EndFunc

; Helper to highlight a skill label when used
Func HighlightSkillLabel($slot)
    GUICtrlSetBkColor($SkillLabels[$slot-1], 0xFFFF00) ; Yellow
    AdlibRegister("_UnhighlightSkillLabel" & $slot, 200)
EndFunc

Func _UnhighlightSkillLabel1()
    GUICtrlSetBkColor($SkillLabels[0], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel1")
EndFunc
Func _UnhighlightSkillLabel2()
    GUICtrlSetBkColor($SkillLabels[1], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel2")
EndFunc
Func _UnhighlightSkillLabel3()
    GUICtrlSetBkColor($SkillLabels[2], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel3")
EndFunc
Func _UnhighlightSkillLabel4()
    GUICtrlSetBkColor($SkillLabels[3], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel4")
EndFunc
Func _UnhighlightSkillLabel5()
    GUICtrlSetBkColor($SkillLabels[4], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel5")
EndFunc
Func _UnhighlightSkillLabel6()
    GUICtrlSetBkColor($SkillLabels[5], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel6")
EndFunc
Func _UnhighlightSkillLabel7()
    GUICtrlSetBkColor($SkillLabels[6], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel7")
EndFunc
Func _UnhighlightSkillLabel8()
    GUICtrlSetBkColor($SkillLabels[7], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel8")
EndFunc


Func Out($TEXT)
    Local $TIME = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] - "
    Local $TEXTLEN = StringLen($TEXT)
    Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GUIActionsEditExtended)
    If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GUIActionsEditExtended, StringRight(_GUICtrlEdit_GetText($GUIActionsEditExtended), 30000 - $TEXTLEN - 1000))
    _GUICtrlEdit_AppendText($GUIActionsEditExtended, @CRLF & $TIME & $TEXT)
    _GUICtrlEdit_Scroll($GUIActionsEditExtended, 1)
EndFunc

; Log to Extra tab
Func OutExtra($TEXT)
    Local $TIME = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] - "
    Local $TEXTLEN = StringLen($TEXT)
    Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GUIExtraEdit)
    If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GUIExtraEdit, StringRight(_GUICtrlEdit_GetText($GUIExtraEdit), 30000 - $TEXTLEN - 1000))
    _GUICtrlEdit_AppendText($GUIExtraEdit, @CRLF & $TIME & $TEXT)
    _GUICtrlEdit_Scroll($GUIExtraEdit, 1)
    UpdateExtraStatisticsDisplay()
EndFunc

Func UpdateExtraStatisticsDisplay()
    ; Always update coordinates, even if bot is not initialized
    Local $currentX = 0
    Local $currentY = 0
    
    If $BotInitialized Then
        $currentX = Round(X(-2))
        $currentY = Round(Y(-2))
    EndIf
    
    GUICtrlSetData($ExtraStatCoordsLabel, "Coords: (" & $currentX & ", " & $currentY & ")")
    
    ; Only update other stats if bot is initialized
    If $BotInitialized Then
        GUICtrlSetData($ExtraStatDeathsLabel, "Deaths: " & $Stat_Deaths)
        GUICtrlSetData($ExtraStatTotalRunsLabel, "Total Runs: " & $Stat_TotalRuns)
        GUICtrlSetData($ExtraStatTotalRunTimeLabel, "Total Run Time: " & $Stat_TotalRunTime & "s")
        GUICtrlSetData($ExtraStatAvgRunTimeLabel, "Avg Run Time: " & $Stat_AvgRunTime & "s")
        GUICtrlSetData($ExtraStatGoldsLabel, "Golds picked up: " & $Stat_Golds)
        GUICtrlSetData($ExtraStatPurplesLabel, "Purples picked up: " & $Stat_Purples)
        GUICtrlSetData($ExtraStatBluesLabel, "Blues picked up: " & $Stat_Blues)
        GUICtrlSetData($ExtraStatWhitesLabel, "Whites picked up: " & $Stat_Whites)
        GUICtrlSetData($ExtraStatLuxonFactionLabel, "Luxon Faction: " & $Stat_LuxonFaction & " / " & $Stat_LuxonFactionMax)
        GUICtrlSetData($ExtraStatLuxonDonatedLabel, "Luxon Donated: " & $Stat_LuxonDonated)
        GUICtrlSetData($ExtraStatCurrentGoldLabel, "Current Gold: " & $Stat_CurrentGold)
        GUICtrlSetData($ExtraStatGoldPickedUpLabel, "Gold Picked Up: " & $Stat_GoldPickedUp)
    EndIf
EndFunc

