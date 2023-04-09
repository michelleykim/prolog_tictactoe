% board is a list of lists
board([[-,-,-],[-,-,-],[-,-,-]]).
score([[4,2,4],[2,6,2],[4,2,4]]).

% display the board
display_mini_board([Row1, Row2, Row3]) :-
    display_row(Row1), nl,
    display_row(Row2), nl,
    display_row(Row3), nl.

display_row([Player1, Player2, Player3]) :-
    write(' '), write(Player1), write(' '), write(Player2), write(' '), write(Player3).

display_gigaboard([Row1, Row2, Row3]) :-
    display_gigarow(Row1), nl, nl,
    display_gigarow(Row2), nl, nl,
    display_gigarow(Row3), nl, nl.

display_gigarow([Player1, Player2, Player3]) :-
    write('  '), write(Player1), write('  '), write(Player2), write('  '), write(Player3).


% check for winning positions
win_position(Player, Board) :- 
    win_row(Player, Board);
    win_column(Player, Board);
    win_diagonal(Player, Board).

win_row(Player, Board) :-
    member([Player, Player, Player], Board).

win_column(Player, Board) :-
    nth0(0, Board, [Player, _, _]),
    nth0(1, Board, [Player, _, _]),
    nth0(2, Board, [Player, _, _]);
    nth0(0, Board, [_, Player, _]),
    nth0(1, Board, [_, Player, _]),
    nth0(2, Board, [_, Player, _]);
    nth0(0, Board, [_, _, Player]),
    nth0(1, Board, [_, _, Player]),
    nth0(2, Board, [_, _, Player]).

win_diagonal(Player, Board) :-
    nth0(0, Board, [Player, _, _]),
    nth0(1, Board, [_, Player, _]),
    nth0(2, Board, [_, _, Player]);
    nth0(0, Board, [_, _, Player]),
    nth0(1, Board, [_, Player, _]),
    nth0(2, Board, [Player, _, _]).

% check for valid moves
check_valid(Board, Row, Column) :-
    integer(Row),
    integer(Column),
    nth0(Row, Board, Rows),
    nth0(Column, Rows, '-').

% make a move
replace(Row, Column, Player, Board, NewBoard) :-
    nth0(Row, Board, Rows),
    replace_elem(Rows, Column, Player, NewRow),
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

% tie breaker
break_tie(Board, ScoreBoard, Winner) :-
	write('Winner is chosen based off scores off from claimed cells.'), nl,
	player_score('X', Board, ScoreBoard, XScore),
    player_score('O', Board, ScoreBoard, OScore),
    write('X score: '), write(XScore), nl,
    write('O score: '), write(OScore), nl,
    (
        XScore > OScore,
        Winner = 'X'
    ;
        XScore < OScore,
        Winner = 'O'
    ),
	declare_winner(Winner).

player_score(_, [], [], 0).
player_score(Player, [Row|Rows], [ScoreRow|ScoreRows], Score) :-
    row_score(Player, Row, ScoreRow, RowScore),
    player_score(Player, Rows, ScoreRows, AccScore),
    Score is RowScore + AccScore.

row_score(_, [], [], 0).
row_score(Player, [Player|Cols], [Score|ScoreCols], FinalScore) :-
    row_score(Player, Cols, ScoreCols, AccScore),
    FinalScore is AccScore + Score.
row_score(Player, [_|Cols], [_|ScoreCols], Score) :-
    row_score(Player, Cols, ScoreCols, Score).

% declare winner
declare_winner(Player) :-
    write('Player '), write(Player), write(' wins the SUPER tic-tac-toe!'), nl.

declare_mini_winner(Player) :-
    write('Player '), write(Player), write(' wins the mini tic-tac-toe!'), nl.

% declare start of turn
declare_mini_turn(Player) :-
    write('Player '), write(Player), write('\'s turn.'), nl.

% declare gigaturn
declare_gigaturn(Player) :-
    write('Player '), write(Player), write('\'s gigaturn. Choose the board.'), nl.

% parse user input for move
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

switch_player(Player, NewPlayer) :-
    (
        Player = 'X',
        NewPlayer = 'O'
    ;
        Player = 'O',
        NewPlayer = 'X'
    ).

find_winner(Board, Player) :-
    win_position(Player, Board).

play :- 
    board(Board),
    play(Board, 'X').

play(GigaBoard, Player) :-
    declare_gigaturn(Player),
    display_gigaboard(GigaBoard),
    % choose miniboard
    repeat,
    parse_input(GigaBoard, Row, Column),
    !,
    random_member(RandomPlayer, ['O','X']),
    board(MiniBoard),
    mini_play(MiniBoard, RandomPlayer, Winner),
    % reflect result on gigaboard
    replace(Row, Column, Winner, GigaBoard, NewGigaBoard),
    % continue until gigaboard has a winner
    (
        win_position(Player, NewGigaBoard),
        declare_winner(Player)
    ;   tie_position(NewGigaBoard),
        write('Tie!')
    ;
        switch_player(Player, NewPlayer),
        play(NewGigaBoard, NewPlayer)
    ).

mini_play(Board, Player, Winner) :-
    declare_mini_turn(Player),
    display_mini_board(Board),
    repeat,
    parse_input(Board, Row, Column),
    !,
    replace(Row, Column, Player, Board, NewBoard),
    (
        win_position(Player, NewBoard),
        declare_mini_winner(Player),
        Winner = Player
    ;   tie_position(NewBoard),
        write('Tie!'), nl,
        score(ScoreBoard),
        break_tie(NewBoard, ScoreBoard, Winner)
    ;
        switch_player(Player, NewPlayer),
        mini_play(NewBoard, NewPlayer, Winner)
    ).
