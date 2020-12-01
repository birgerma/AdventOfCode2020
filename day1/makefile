NAME:=main
START:=main

ARG:="example.input"

compile:
	erl -compile ${NAME}

run: compile
	erl -noshell -s ${NAME} ${START} ${ARG}
