run: main.o
	./main.o 10 100 false

main.o: main.cpp
	g++ main.cpp -o main.o