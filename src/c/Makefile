CC = clang++
CFLAG = -Wall -Werror -std=c++11

SRC = main.cc
OBJ = ${SRC:cc=o} 
APP = ${SRC:.cc=}

.PHONY: all
all: ${APP}

${APP} : % : %.o Makefile
	${CC} -v $< -o $@

%.o: %.cc Makefile
	${CC} ${CFLAG} -c $<

clean:
	rm -f ${APP} ${OBJ}

