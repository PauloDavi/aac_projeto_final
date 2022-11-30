GENERTIONS=10
POULATION_SIZE=100
VERBOSE=false

run: main.o
	./main.o $(GENERTIONS) $(POULATION_SIZE) $(VERBOSE)

main.o: main.cpp
	g++ main.cpp -o main.o