
%.o : %.s
	as $< -o $@ 

all: assemblynoid.o levels.o drawing.o terminal.o powerup.o ball.o utils.o enemies.o
	ld assemblynoid.o levels.o drawing.o terminal.o powerup.o ball.o utils.o enemies.o -o assemblynoid 
	#./assemblynoid

#build:
#	as assemblynoid.s -o assemblynoid.o 
#	ld assemblynoid.o -o assemblynoid
#	./arkanoid

clean:
	rm assemblynoid *.o .*.swp
