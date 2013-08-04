-- �ٶ����ԣ����Բ���ʾӰ�죬ͨ����������
local prop_speed_tbl =
{
	minium = 1,	-- ��Сֵ
	maxium = 10	-- ���ֵ
}

local prop_attack_tbl =
{
	minium = 1,	-- ��Сֵ
	maxium = 7
}

local prop_hitpoint_tbl =
{
	minium = 1, -- ��Сֵ
	maxium = 10
}

-- ��ʼ���������
math.randomseed(os.time());

-- �õ��������������Сֵ�趨
-- @param maxnum ���ֵ�����ֵ
-- @param minium ���ֵ����Сֵ
local genRand = function(maxnum, minium)
	minium = minium or 0;
	return math.floor(math.random()*100000 % maxnum + minium);
end

-- ��������ƿ�
-- @param total ���ɵ��ƿ�����
local generate_card_heap = function(total)
	local card_heap = {};
	
	for i = 1, total do
		local speed = genRand(prop_speed_tbl.maxium, prop_speed_tbl.minum);
		local attack = genRand(prop_attack_tbl.maxium, prop_attack_tbl.minium);
		local hp = genRand(prop_hitpoint_tbl.maxium, prop_hitpoint_tbl.minium);
		
		local card_data =
		{
			speed = speed,
			attack = attack,
			hp = hp
		};
		
		table.insert(card_heap, card_data);
	end
	
	return card_heap;
end

-- ���濨�����ݵ��ļ�
-- @param card_heap ���ɵ��ƿ�
local storeDataToFile = function(card_heap)
	local data = {};
	for idx, card in ipairs(card_heap) do
		local c_data = string.format("%d\t%d\t%d\t%d", idx, card.attack, card.hp, card.speed);
		print(c_data);
		table.insert(data, c_data);
	end
	
	local file = io.open("card_data.txt", "w+b");

	if file then
		file:write(table.concat(data, "\n"));
		file:close();
	end
end

-- ���ļ��ж�ȡ�������ݵ��ڴ�
local readCardData = function()

	local readFile = io.open("card_data.txt", "r+b");
	
	local card_heap = {};
	
	if readFile then
		-- ��ȡ�ļ����ݣ����У�
		local card_data = readFile:read("*l");
		
		while (card_data ~= nil) do
--			print(card_data);
			local card = {};
			card.num, card.attack, card.hp, card.speed = string.match(card_data, "(%d+)%s(%d+)%s(%d+)%s(%d+)");
--			print(card.num, card.attack, card.hp, card.speed);

			-- ����ʤ��������ս�ܴ���
			card.winCnts = 0;
			card.loseCnts = 0;
			table.insert(card_heap, card);
--			print(#card_heap);
			card_data = readFile:read("*l");
		end
		
		readFile:close();
	end
	
	return card_heap;
end

-- ���ƿ��л��3�ſ���
-- @param card_store �ƿ�
-- @param side ����ID��һ����1��2����ʾ����������
-- @param counts ȡ���ſ��ƣ�Ĭ��3��
local chooseCardFromStore = function(card_store, side, counts)

	counts = counts or 3;
--	print(#card_store);
	
	local battle_cards = {};
	
	local cn = {};
	for i=1,counts do
		table.insert(cn, genRand(#card_store, 1));
	end
	
	for idx, cardNum in ipairs(cn) do
		local cardData = {};
		local cd = card_store[cardNum];
		if cd == nil then
			error(string.format("cardNum is %d", cardNum));
		end
		for k, v in pairs(cd) do
			cardData[k] = tonumber(v);
		end
		
		cardData.side = side;
		--  ����ѡ��������
		table.insert(battle_cards, cardData);
	end
	
	return battle_cards;
end

local copyTbl = function(tbl)
	local retTbl = {};
	for k, v in pairs(tbl) do
		retTbl[k] = v;
	end
	return retTbl;
end

-- �ٶ�����
-- @param bc1 ����1
-- @param bc2 ����2
local speedSort = function(bc1, bc2)
	-- �ϲ��ƣ��õ����幥��˳��
	local attack_sequence = {};
	
	for k, v in ipairs(bc1) do
		table.insert(attack_sequence, v);
	end
	
	for k, v in ipairs(bc2) do
		table.insert(attack_sequence, v);
	end
	
--	print("attack_sequence's count", #attack_sequence);
		
	-- ѭ���ƿ⣬�õ��ٶȱ�ֵ
	table.sort(attack_sequence, function(one, two)
		return one.speed > two.speed
	end);
	
	return attack_sequence;
end

-- ���Ը���ս��������ʾ��Ӧ�Ĺ�����Ѫ�����ٶȵ�����
-- @param sequence ���б�
-- @param side ��ѡ��������ʾ��Ӧһ��������
local showBattleCard = function(sequence, side)
	for k, v in ipairs(sequence) do
		if side then
			if v.side == side then
				print(string.format("cardNum:%d\tattack:%d\thp:%d\tspeed:%d\tside:%d", v.num, v.attack, v.hp, v.speed, v.side));
			end
		else
			print(string.format("cardNum:%d\tattack:%d\thp:%d\tspeed:%d\tside:%d", v.num, v.attack, v.hp, v.speed, v.side));
		end
	end
end

-- ��ʾս����ս���Ŀ��ƣ�����δ��ս��
-- @param card_store �ƿ�
-- @param bExcel ����excel������м���tab���ָ�
local showDataAfterBattle = function(card_store, bExcel)
	for k, card in ipairs(card_store) do
		-- ����δ��ս
		if card.winCnts + card.loseCnts > 0 then
			if bExcel then
				print(card.num, card.attack, card.hp, card.speed, (card.attack + card.hp + math.floor(card.speed/100)), card.winCnts, card.loseCnts, card.winCnts/(card.winCnts + card.loseCnts))
			else
				print(string.format("CardID:%04d, Attack:%d, HP:%d, Speed:%d, TotalAbility:%d, WinCnts:%d, LoseCnt:%d, WinPercent:%.2f%%", 
				card.num, card.attack, card.hp, card.speed, (card.attack + card.hp + math.floor(card.speed/100)), card.winCnts, card.loseCnts, card.winCnts/(card.winCnts + card.loseCnts)*100));
			end
		end
	end
end

-- ���õ�����ʤ����ʧ�ܴ���
-- @param cardStore �����趨��¼ÿ�ſ��Ƶ�ս�����ݵı��±�����Ƶ�ID
-- @param card_group ��Ӧ������
-- @param winOrLose ��ʾ��ǰ�����Ӯ ֵ win ��ʾʤ���������ʾʧ��
local markCardFightResult = function(cardStore, card_groupe, winOrLose)

	for k, card in ipairs(card_groupe) do
		local cardID = card.num
		
		local cardData = cardStore[cardID];
		
		if not cardData then
			error("cardData is nil");
			return
		end
		
		if winOrLose and winOrLose == "win" then
			cardData.winCnts = cardData.winCnts + 1;
		else
			cardData.loseCnts = cardData.loseCnts + 1;
		end
	end
end

-- �õ�����˳�������У��ڲ�����ȫ�����ã�
-- @param �������Ʊ�
local getDefenderSequence = function(cardDefenderGroup)
	-- �õ�һ����������˳��������
	local defenderSequence = {};
	-- ��������˳������飬��������������������򣬹�������ؿ��Ƶ����ظ��������о������ص�˳��
	local assistSequence = {}
	local assistRndSequence = {}
	-- ���ݶ�ս��Ŀ��ƶ�����������������
	for idx = 1, #cardDefenderGroup do
		table.insert(assistSequence, idx)
	end
	
	-- ѭ����������˳��
	while #assistSequence > 0 do
		-- ���һ��λ��
		local rnd = genRand(#assistSequence, 1)
		-- ������ó���λ�õĿ��Ʒ���˳�������
		table.insert(assistRndSequence, assistSequence[rnd]);
		-- ����˳��Ŀ��Ƴ�����
		table.remove(assistSequence, rnd);
	end
		
	-- ���ݾ�����˳�����ɷ��ظ�������
	for key, value in ipairs(assistRndSequence) do
		table.insert(defenderSequence, cardDefenderGroup[value])
	end
		
	return defenderSequence
end

-- ��������
-- @param card1 ��һ�鿨��
-- @param card2 �ڶ��鿨��
-- @param card_store �ܿ��Ʊ����Լ�¼ÿ�ſ��Ƶ�ս������
local attackTest = function(card1, card2, card_store)
	-- �õ�����������ٶ������б�
	local sequence = speedSort(card1, card2);
	
--	showBattleCard(sequence);
	
	local idx = nil;
	-- ������Ѫ��
	local nTotalHP1 = 0;
	local nTotalHP2 = 0;
	for idx = 1, 6 do
		local card = sequence[idx];
		if card.side == 1 then
			nTotalHP1 = nTotalHP1 + card.hp;
		elseif card.side == 2 then
			nTotalHP2 = nTotalHP2 + card.hp;
		end
	end
	
-- 	print("Player1 total HP is ", nTotalHP1);
-- 	print("Player2 total HP is ", nTotalHP2);
	
	local nCircle = 1;
	local nAttackCnt = 0;
	-- ѭ��������
	idx = 1;
	while idx <= 6 do
		-- ������
		local cardAttacker = sequence[idx];
		-- ��Ӫ
		local sideAttack = cardAttacker.side;
		if cardAttacker.hp > 0 then	-- ���Ź������ĵ�λ
			--[[ ս���У������������ѡ�ط���λ��������
				ʹ�����ѡ��з����������㷨
				1. ���ȵõ�1��3�������
				2.���ʵз����ƣ��õ���Ӧ��num
				3.������ս��
			--]]
			local cardDefenderGroup = nil
			if sideAttack == 1 then
				cardDefenderGroup = card2
			else
				cardDefenderGroup = card1
			end
			
			-- �õ�һ����������˳��������
			local defenderSequence = getDefenderSequence(cardDefenderGroup)
			
			-- ���ѭ��3�Σ����ض��еĳ��ȣ���ֻҪ������һ�����̽���
			for idxDefender, cardDefender in ipairs(defenderSequence) do
				
				assert(cardDefender.side ~= sideAttack, "Defender side wrong")

				-- �жϷ��ط��Ƿ�����������ѡ����һ�����ط�
				if cardDefender.hp > 0 then
					-- ����ս������������1
					nAttackCnt = nAttackCnt + 1
					
					-- �������ڿ�Ѫ��
					local deltaBlood = 0;
					if cardAttacker.attack < cardDefender.hp then
						deltaBlood = cardAttacker.attack
					else
						deltaBlood = cardDefender.hp
					end
					
					-- ���ط���Ѫ����ȥ�����������������Ի���
					cardDefender.hp = cardDefender.hp - cardAttacker.attack
					
					-- ���ط��Ŷӿ�Ѫ
					if cardDefender.side == 1 then
						nTotalHP1 = nTotalHP1 - deltaBlood
					elseif cardDefender.side == 2 then
						nTotalHP2 = nTotalHP2 - deltaBlood
					end
					
					-- �����������������ؿ�Ѫѭ������ʼѡ����һ����������
					break
				end
			end
			
--[[			ս���У�ͳһ��ѡ�з���һ�ſ�����Ϊ�����������

			-- ѭ���õ���һ�����ŵĵжԵ�λ
			for idxInside = 1, 6 do
				local cardTmp = sequence[idxInside];
				
				if sideAttack ~= cardTmp.side and cardTmp.hp > 0 then
					nAttackCnt = nAttackCnt + 1;
-- 					print(string.format("=============circle %d=============", nCircle));
-- 					print(string.format("attacker's id is %d, defender's id is %d", cardAttacker.num, cardTmp.num));
					local delta = 0;
					if cardAttacker.attack < cardTmp.hp then
						delta = cardAttacker.attack
					else
						delta = cardTmp.hp
					end
					
-- 					print("===>Delta is ", delta);
-- 					print(string.format("Attacker side is %d, Defender side is %d", cardAttacker.side, cardTmp.side));
-- 					print(string.format("Attacker card is %d, Defender card is %d", cardAttacker.num, cardTmp.num));
					
					-- ��ȥ������
					cardTmp.hp = cardTmp.hp - cardAttacker.attack;
					
					if cardTmp.side == 1 then
						nTotalHP1 = nTotalHP1 - delta;
					elseif cardTmp.side == 2 then
						nTotalHP2 = nTotalHP2 - delta;
					end

-- 					print("Player1's total HP", nTotalHP1);
-- 					print("Player2's total HP", nTotalHP2);		
-- 					showBattleCard(sequence);
-- 					print("=============circle end=============");
					break
				end
			end
--]]
		end		
		-- �Ƿ���һ����Ѫ��0�����ս��
		if nTotalHP1 <= 0 then
-- 			print("Winner is Player1, circle", nCircle, "Attacks", nAttackCnt);
			break;
		elseif nTotalHP2 <= 0 then
-- 			print("Winner is Player2, circle", nCircle, "Attacks", nAttackCnt);
			break;
		end
		
		idx = idx + 1;
		-- ��ʼ�µ�һ��
		if idx > 6 then
			nCircle = nCircle + 1;
			idx = 1;
		end
	end
	
	-- ѭ����񣬵õ���Ӧ��ID��Ȼ������������ʧ�ܴ���
	if card_store then
		if nTotalHP1 <= 0 then
			-- ����2���Ƶ�ʤ������
			markCardFightResult(card_store, card2, "win");
			markCardFightResult(card_store, card1, "lose");
		else
			markCardFightResult(card_store, card1, "win");
			markCardFightResult(card_store, card2, "lose");
		end
	end
--	print("=============================Attack=============================");
	return sequence;
end

-- �������ɵ�����ƿ⵽�ļ�
-- storeDataToFile(generate_card_heap(200));

-- �õ����ļ��е��ƿ⵽�ڴ��
local card_store = readCardData();

-- print("card_store's count", #card_store);

-- �õ�������ս�Ʊ�
-- local card_1 = chooseCardFromStore(card_store, 1)
-- local card_2 = chooseCardFromStore(card_store, 2)

-- �õ������������н�����ı�
-- local sequence = attackTest(card_1, card_2, card_store);

-- ���ս��Ľ��
-- showBattleCard(sequence);

for i = 1, 200000 do
	attackTest(chooseCardFromStore(card_store, 1), chooseCardFromStore(card_store, 2), card_store);
end

showDataAfterBattle(card_store, true);
