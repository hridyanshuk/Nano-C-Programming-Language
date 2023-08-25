assembly: a.out libAS6_23.a
	./a.out 1 > ./output/AS6_23_quads1.out
	./a.out 2 > ./output/AS6_23_quads2.out
	./a.out 3 > ./output/AS6_23_quads3.out
	./a.out 4 > ./output/AS6_23_quads4.out
	./a.out 5 > ./output/AS6_23_quads5.out

	gcc -c ./asmFile/AS6_23_1.s -o ./objectFiles/AS6_23_1.o
	gcc -c ./asmFile/AS6_23_2.s -o ./objectFiles/AS6_23_2.o
	gcc -c ./asmFile/AS6_23_3.s -o ./objectFiles/AS6_23_3.o
	gcc -c ./asmFile/AS6_23_4.s -o ./objectFiles/AS6_23_4.o
	gcc -c ./asmFile/AS6_23_5.s -o ./objectFiles/AS6_23_5.o

	gcc ./objectFiles/AS6_23_1.o -o ./executable/test1 -L. -lAS6_23 -no-pie
	gcc ./objectFiles/AS6_23_2.o -o ./executable/test2 -L. -lAS6_23 -no-pie
	gcc ./objectFiles/AS6_23_3.o -o ./executable/test3 -L. -lAS6_23 -no-pie
	gcc ./objectFiles/AS6_23_4.o -o ./executable/test4 -L. -lAS6_23 -no-pie
	gcc ./objectFiles/AS6_23_5.o -o ./executable/test5 -L. -lAS6_23 -no-pie

libAS6_23.a:
	gcc -c AS6_23.c
	ar -rcs libAS6_23.a AS6_23.o

a.out: lex.yy.o AS6_23.tab.o AS6_23_translator.o AS6_23_target_translator.o
	g++ lex.yy.o AS6_23.tab.o AS6_23_translator.o AS6_23_target_translator.o -lfl -o a.out

AS6_23_target_translator.o: AS6_23_target_translator.cpp
	g++ -c AS6_23_target_translator.cpp

AS6_23_translator.o: AS6_23_translator.cpp AS6_23_translator.h
	g++ -c AS6_23_translator.h
	g++ -c AS6_23_translator.cpp

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

AS6_23.tab.o: AS6_23.tab.c
	g++ -c AS6_23.tab.c

lex.yy.c: AS6_23.l AS6_23.tab.h AS6_23_translator.h
	flex AS6_23.l

AS6_23.tab.c: AS6_23.y
	bison -dtv AS6_23.y -W

AS6_23.tab.h: AS6_23.y
	bison -dtv AS6_23.y -W


	
clean:
	rm lex.yy.c
	rm AS6_23.tab.c
	rm AS6_23.tab.h
	rm lex.yy.o
	rm AS6_23.tab.o
	rm AS6_23.output
	rm AS6_23_translator.o
	rm ./executable/test1
	rm ./executable/test2
	rm ./executable/test3
	rm ./executable/test4
	rm ./executable/test5
	rm a.out
	rm AS6_23_target_translator.o
	rm AS6_23_translator.h.gch
	rm ./output/AS6_23_quads1.out
	rm ./output/AS6_23_quads2.out
	rm ./output/AS6_23_quads3.out
	rm ./output/AS6_23_quads4.out
	rm ./output/AS6_23_quads5.out
	rm libAS6_23.a
	rm AS6_23.o
	rm ./objectFiles/AS6_23_1.o
	rm ./objectFiles/AS6_23_2.o
	rm ./objectFiles/AS6_23_3.o
	rm ./objectFiles/AS6_23_4.o
	rm ./objectFiles/AS6_23_5.o
	rm ./asmFile/AS6_23_1.s
	rm ./asmFile/AS6_23_2.s
	rm ./asmFile/AS6_23_3.s
	rm ./asmFile/AS6_23_4.s
	rm ./asmFile/AS6_23_5.s
