
# 83,abecedari,N1110,abc,N1110,



import sys ;

leng = {};
gasc = {}; 

for line in open(sys.argv[1]).readlines(): #{
	row = line.strip().split(','); 
	if len(row) < 4: #{
		continue;
	#}
	lem = row[1];
	tag = row[2];
	if (lem, tag) not in leng: #{
		leng[(lem, tag)] = [];
	#}		
	leng[(lem, tag)].append((row[3], row[4]));
#}

for line in open(sys.argv[2]).readlines(): #{
	row = line.strip().split(','); 
	if len(row) < 4: #{
		continue;
	#}
	lem = row[1];
	tag = row[2];
	if (lem, tag) not in gasc: #{
		gasc[(lem, tag)] = [];
	#}		
	gasc[(lem, tag)].append((row[3], row[4]));
#}

gasc_k = set(gasc.keys());
leng_k = set(leng.keys());

both = leng_k.intersection(gasc_k);
all = leng_k.union(gasc_k);
leng_o = leng_k - both ;
gasc_o = gasc_k - both ;

print(len(all), len(both), len(leng_o), len(gasc_o), file=sys.stderr);

for i in both: #{
	for j in leng[(i[0], i[1])]: #{
		print('%s\t%s\t%s\t%s\t%s' % ('both', i[0], i[1], j[0], j[1]));
	#}
#}

for i in leng_o: #{
	for j in leng[(i[0], i[1])]: #{
		print('%s\t%s\t%s\t%s\t%s' % ('leng', i[0], i[1], j[0], j[1]));
	#}
#}

for i in gasc_o: #{
	for j in gasc[(i[0], i[1])]: #{
		print('%s\t%s\t%s\t%s\t%s' % ('gasc', i[0], i[1], j[0], j[1]));
	#}
#}
