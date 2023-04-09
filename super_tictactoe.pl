% board is a list of lists
% board([[-,-,-],[-,-,-],[-,-,-]]).

% display the board
display_board([Row1, Row2, Row3]) :-
    display_row(Row1), nl,
    display_row(Row2), nl,
    display_row(Row3), nl.

display_row([Symbol1, Symbol2, Symbol3]) :-
    write(' '), write(Symbol1), write(' '), write(Symbol2), write(' '), write(Symbol3).

% check for winning positions
win_position(Symbol, Board) :- 
    win_row(Symbol, Board);
    win_column(Symbol, Board);
    win_diagonal(Symbol, Board).

win_row(Symbol, Board) :-
    member([Symbol, Symbol, Symbol], Board).

win_column(Symbol, Board) :-
    nth0(0, Board, [Symbol, _, _]),
    nth0(1, Board, [Symbol, _, _]),
    nth0(2, Board, [Symbol, _, _]);
    nth0(0, Board, [_, Symbol, _]),
    nth0(1, Board, [_, Symbol, _]),
    nth0(2, Board, [_, Symbol, _]);
    nth0(0, Board, [_, _, Symbol]),
    nth0(1, Board, [_, _, Symbol]),
    nth0(2, Board, [_, _, Symbol]).

win_diagonal(Symbol, Board) :-
    nth0(0, Board, [Symbol, _, _]),
    nth0(1, Board, [_, Symbol, _]),
    nth0(2, Board, [_, _, Symbol]);
    nth0(0, Board, [_, _, Symbol]),
    nth0(1, Board, [_, Symbol, _]),
    nth0(2, Board, [Symbol, _, _]).

% check for valid moves
check_valid(Board, Row, Column) :-
    integer(Row),
    integer(Column),
    nth0(Row, Board, Rows),
    nth0(Column, Rows, '-').

% make a move
replace(Row, Column, Symbol, Board, NewBoard) :-
    nth0(Row, Board, Rows),
    replace_elem(Rows, Column, Symbol, NewRow),
    replace_elem(Board, Row, NewRow, NewBoard).

% replace an element in a list to another
replace_elem([_|T], 0, X, [X|T]).
replace_elem([H|T], I, X, [H|N]) :-
    I > 0,
    J is I - 1,
    replace_elem(T, J, X, N).

% tie position
tie_position([Row1, Row2, Row3]) :-
    \+ member(-, Row1),
    \+ member(-, Row2),
    \+ member(-, Row3).

% declare winner
declare_winner(Symbol) :-
    write('Player '), write(Symbol), write(' wins!'), nl.

% declare start of turn
declare_turn(Symbol) :-
    write('Player '), write(Symbol), write(' turn.'), nl.

% parse user input
parse_input(Board, Row, Column) :-
    read_row(Row),
    read_column(Column),
    (check_valid(Board, Row, Column) -> true ; (write('Invalid move!'), nl, fail)).

read_row(Row) :-
    write('Enter row: '),
    read_string(user_input, "\n", "\r", _, RowStr),
    (number_string(Row, RowStr) -> true ; (write('Invalid row input!'), nl, fail)).

read_column(Column) :-
    write('Enter column: '),
    read_string(user_input, "\n", "\r", _, ColumnStr),
    (number_string(Column, ColumnStr) -> true ; (write('Invalid column input!'), nl, fail)).

switch_player(Symbol, NewSymbol) :-
    (
        Symbol = 'X',
        NewSymbol = 'O'
    ;
        Symbol = 'O',
        NewSymbol = 'X'
    ).

play :-
    play([[-,-,-],[-,-,-],[-,-,-]], 'X').

play(Board, Symbol) :-
    declare_turn(Symbol),
    display_board(Board),
    repeat,
    parse_input(Board, Row, Column),
    (check_valid(Board, Row, Column) -> true ; (write('Invalid move!'), nl, fail)),
    !,
    replace(Row, Column, Symbol, Board, NewBoard),
    (
        win_position(Symbol, NewBoard),
        declare_winner(Symbol)
    ;   tie_position(NewBoard),
        write('Tie!')
    ;
        switch_player(Symbol, NewSymbol),
        play(NewBoard, NewSymbol)
    ).
