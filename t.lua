-- ��ʼ���������
math.randomseed(os.time());

-- �õ��������������Сֵ�趨
local genRand = function(maxnum, minium)
	minium = minium or 0;
	return math.floor(math.random()*100000 % (maxnum) + minium);
end

for i=0, 100000 do
	local value = genRand(200, 1);
	if value >= 201 or value <= 0 then
		print(value);
	end
end

-- �õ�����˳�������У��ڲ�����ȫ�����ã�
local getDefenderSequence = function(cardDefenderGroup)
	-- �õ�һ����������˳��������
	local defenderSequence = {};
	-- ��������˳������飬��������������������򣬹�������ؿ��Ƶ����ظ��������о������ص�˳��
	local assistSequence1 = {1, 2, 3}
	local assistSequence2 = {}
	
	-- ѭ����������˳��
	while #assistSequence1 > 0 do
		-- ���һ��λ��
		local rnd = genRand(#assistSequence1, 1)
		-- ������ó���λ�õĿ��Ʒ���˳�������
		table.insert(assistSequence2, assistSequence1[rnd]);
		-- ����˳��Ŀ��Ƴ�����
		table.remove(assistSequence1, rnd);
	end
		
	-- ���ݾ�����˳�����ɷ��ظ�������
	for key, value in ipairs(assistSequence2) do
		table.insert(defenderSequence, cardDefenderGroup[value])
	end
		
	return defenderSequence
end

local cardGroup = {100, 200, 300}

for idx = 1, 100 do
	local seq = getDefenderSequence(cardGroup)

	table.foreach(seq, print)
	print(idx, "=====================")
end
