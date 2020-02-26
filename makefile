a.out: al.l
	flex --outfile=al.c al.l
	gcc  al.c

clean:
	rm *.c
	rm *.out
