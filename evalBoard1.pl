%% EvalBoard 1 (Heuristic 1)
%% For each position on the board, 
%% traverse the 5 next positions in each direction,
%% and count the number of player markers and opponent markers.
%% Add to the total score of the board, a score relative to the number
%% of each type of marker


%%%%% Attribute a score to each consecutive sets of player/opponent marker alignements
getScore(1, 0, 1) :-
    !.
getScore(2, 0, 10) :-
    !.
getScore(3, 0, 100) :-
    !.
getScore(4, 0, 1000) :-
    !.
getScore(5, 0, 10000000000000) :-
    !.

getScore(0, 1, -1) :-
    !.
getScore(0, 2, -10) :-
    !.
getScore(0, 3, -100) :-
    !.
getScore(0, 4, -1000) :-
    !.
getScore(0, 5, -10000000000000) :-
    !.

getScore(_, _, 0) :-
    !.

%%%%% Increment the count of player/oppent markers in a row
incrementCount(Player, Elem, PlyCount, OppCount, NewPlyCount, NewOppCount) :-
    Elem==Player,
    NewPlyCount is PlyCount+1,
    NewOppCount is OppCount.
incrementCount(_, _, PlyCount, OppCount, NewPlyCount, NewOppCount) :-
    NewPlyCount is PlyCount,
    NewOppCount is OppCount+1.

%%%%% Recursively calculate the total value of a given state of the board to the player
evalBoard1(Board, Player, BoardScore) :-
    evalBoardHori(Board, Player, 0, TotalHScore, 0),
    evalBoardVert(Board, Player, 0, TotalVScore, 0),
    evalBoardLeftDiag(Board, Player, 0, TotalLDScore, 0),
    evalBoardRightDiag(Board, Player, 0, TotalRDScore, 0),
    BoardScore is TotalHScore+TotalVScore+TotalLDScore+TotalRDScore,
    !.

evalBoardHori(Board, _, TotalScore, TotalScore, BoardLength) :-
    length(Board, BoardLength).
evalBoardHori(Board, Player, AccScore, TotalHScore, Acc) :-
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    RowLastIndex is BoardDimension-1-4, %%6=11-1-4
    Acc mod BoardDimension=<RowLastIndex,
    evalHori(Board, Player, HScore, Acc, 0, 0, 0),
    NewAccScore is AccScore+HScore,
    NewAcc is Acc+1,
    evalBoardHori(Board, Player, NewAccScore, TotalHScore, NewAcc),
    !.
evalBoardHori(Board, Player, AccScore, TotalHScore, Acc) :-
    NewAcc is Acc+1,
    evalBoardHori(Board, Player, AccScore, TotalHScore, NewAcc),
    !.

evalBoardVert(Board, _, TotalScore, TotalScore, BoardLength) :-
    length(Board, BoardLength).
evalBoardVert(Board, Player, AccScore, TotalVScore, Acc) :-
    Acc=<76,
    evalVert(Board, Player, VScore, Acc, 0, 0, 0),
    NewAccScore is AccScore+VScore,
    NewAcc is Acc+1,
    evalBoardVert(Board, Player, NewAccScore, TotalVScore, NewAcc),
    !.
evalBoardVert(Board, Player, AccScore, TotalVScore, Acc) :-
    NewAcc is Acc+1,
    evalBoardVert(Board, Player, AccScore, TotalVScore, NewAcc),
    !.

evalBoardLeftDiag(Board, _, TotalScore, TotalScore, BoardLength) :-
    length(Board, BoardLength).
evalBoardLeftDiag(Board, Player, AccScore, TotalLDScore, Acc) :-
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    LastIndex is BoardLength-4*BoardDimension-1, %% 76=11*11-4*11-1
    Acc=<LastIndex,
    Acc mod BoardDimension>=4,
    evalLeftDiag(Board, Player, LDScore, Acc, 0, 0, 0),
    NewAccScore is AccScore+LDScore,
    NewAcc is Acc+1,
    evalBoardLeftDiag(Board, Player, NewAccScore, TotalLDScore, NewAcc),
    !.
evalBoardLeftDiag(Board, Player, AccScore, TotalLDScore, Acc) :-
    NewAcc is Acc+1,
    evalBoardLeftDiag(Board, Player, AccScore, TotalLDScore, NewAcc),
    !.

evalBoardRightDiag(Board, _, TotalScore, TotalScore, BoardLength) :-
    length(Board, BoardLength).
evalBoardRightDiag(Board, Player, AccScore, TotalRDScore, Acc) :-
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    LastIndex is BoardLength-4*BoardDimension-1, %% 76=11*11-4*11-1
    Acc=<LastIndex,
    RowLastIndex is BoardDimension-1-4,
    Acc mod BoardDimension=<RowLastIndex,
    evalRightDiag(Board, Player, RDScore, Acc, 0, 0, 0),
    NewAccScore is AccScore+RDScore,
    NewAcc is Acc+1,
    evalBoardRightDiag(Board, Player, NewAccScore, TotalRDScore, NewAcc),
    !.
evalBoardRightDiag(Board, Player, AccScore, TotalRDScore, Acc) :-
    NewAcc is Acc+1,
    evalBoardRightDiag(Board, Player, AccScore, TotalRDScore, NewAcc),
    !.

%%%%% Recursively calculate the total value of a given state of the board to the player - horizontal alignements
evalHori(_, _, HScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, HScore),
    !.
evalHori(Board, Player, HScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    NewIndex is Index+1,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalHori(Board,
             Player,
             HScore,
             NewIndex,
             NewAcc,
             NewPlyCount,
             NewOppCount).
evalHori(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    NewIndex is Index+1,
    NewAcc is Acc+1,
    evalHori(Board,
             Player,
             VScore,
             NewIndex,
             NewAcc,
             PlyCount,
             OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - vertical alignements
evalVert(_, _, VScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, VScore),
    !.
evalVert(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    NewIndex is Index+BoardDimension,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalVert(Board,
             Player,
             VScore,
             NewIndex,
             NewAcc,
             NewPlyCount,
             NewOppCount),
    !.
evalVert(Board, Player, VScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    NewIndex is Index+BoardDimension,
    NewAcc is Acc+1,
    evalVert(Board,
             Player,
             VScore,
             NewIndex,
             NewAcc,
             PlyCount,
             OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - left-diagonal alignements
evalLeftDiag(_, _, LDScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, LDScore),
    !.
evalLeftDiag(Board, Player, LDScore, Index, Acc, PlyCount, OppCount) :-
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    NewIndex is Index+BoardDimension-1,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalLeftDiag(Board,
                 Player,
                 LDScore,
                 NewIndex,
                 NewAcc,
                 NewPlyCount,
                 NewOppCount).
evalLeftDiag(Board, Player, LDScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    NewIndex is Index+BoardDimension-1,
    NewAcc is Acc+1,
    evalLeftDiag(Board,
                 Player,
                 LDScore,
                 NewIndex,
                 NewAcc,
                 PlyCount,
                 OppCount).

%%%%% Recursively calculate the total value of a given state of the board to the player - right-diagonal alignements
evalRightDiag(_, _, RDScore, _, 5, PlyCount, OppCount) :-
    getScore(PlyCount, OppCount, RDScore),
    !.
evalRightDiag(Board, Player, RDScore, Index, Acc, PlyCount, OppCount) :-
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Elem),
    NewAcc is Acc+1,
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    NewIndex is Index+BoardDimension+1,
    incrementCount(Player,
                   Elem,
                   PlyCount,
                   OppCount,
                   NewPlyCount,
                   NewOppCount),
    evalRightDiag(Board,
                  Player,
                  RDScore,
                  NewIndex,
                  NewAcc,
                  NewPlyCount,
                  NewOppCount).
evalRightDiag(Board, Player, RDScore, Index, Acc, PlyCount, OppCount) :-
    Acc=<5,
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
    NewIndex is Index+BoardDimension+1,
    NewAcc is Acc+1,
    evalRightDiag(Board,
                  Player,
                  RDScore,
                  NewIndex,
                  NewAcc,
                  PlyCount,
                  OppCount).
