lexical: al.l
	flex --outfile=al.c al.l
	gcc al.c
