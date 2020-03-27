a.out:  
	bison --yacc --defines --output=al1.c al.y
	flex --outfile=al.c al.l
	gcc  al1.c al.c SymbolTable.c 

clean:
	rm al1.c al.c
	rm *.out
