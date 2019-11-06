%%%% Helper predicates
%%%%% Recursive predicate that makes a copy of specified list but changes one element
partialCopy(_, _, [], []).
partialCopy(RvIndex, Elem, [_|T1], [Elem|T2]) :-
	length(T1, RvIndex),
	partialCopy(RvIndex, Elem, T1, T2),
	!.
partialCopy(RvIndex, Elem, [H|T1], [H|T2]) :-
    partialCopy(RvIndex, Elem, T1, T2).
%%%%% Checks if a given position in the list has not been instanciated
isPosEmpty(Board, Index) :-
    nth0(Index, Board, Elem),
    var(Elem).


%%%% Change player
changePlayer(x, o).
changePlayer(o, x).

%%%%% Recursive predicate that checks if all the elements of the board are instanciated
isBoardFull([]).
isBoardFull([H|T]) :-
    nonvar(H),
    isBoardFull(T).

%%%%% Play a Move, the new Board will be the same, but one value will be instanciated with the Move
playMove(Move, Player, Board, NewBoard) :-
	length(Board, BoardSize),
	ReverseIndex is BoardSize - 1 - Move,
	partialCopy(ReverseIndex, Player, Board, NewBoard).

%%%%% Remove old board save new on in the knowledge base
applyIt(Board, NewBoard) :-
    retract(board(Board)),
    assert(board(NewBoard)).

%%%%% Dynamically check for alignments of player markers on the board
aligned(Board, Player, Size, Count) :-
    length(Board, BoardLength),
    BoardDimension is round(sqrt(BoardLength)),
	alignedHori(Board, 0, Player, Size, HCount, 0, BoardLength, BoardDimension),
	alignedVert(Board, 0, Player, Size, VCount, 0, BoardLength, BoardDimension),
	alignedLeftDiag(Board, 0, Player, Size, LDCount, 0, BoardLength, BoardDimension),
	alignedRightDiag(Board, 0, Player, Size, RDCount, 0, BoardLength, BoardDimension),
	Count is HCount + VCount + LDCount + RDCount.

alignedHori(_, BoardLength, _, _, TotalCount, TotalCount, BoardLength, _).
alignedHori(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	RowLastIndex is BoardDimension-1-(Size-1), %%6=11-1-4
    Acc mod BoardDimension =< RowLastIndex,
	not(isPosEmpty(Board, Acc)),
	nth0(Acc, Board, Player),
	horiOfSize(Board, Acc, Player, 0, Size, BoardDimension),
	NewAcc is Acc + 1,
	NewAccCount is AccCount + 1,
	alignedHori(Board, NewAcc, Player, Size, TotalCount, NewAccCount, BoardLength, BoardDimension),
	!.
alignedHori(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	NewAcc is Acc + 1,
	alignedHori(Board, NewAcc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension),
	!.

alignedVert(_, BoardLength, _, _, TotalCount, TotalCount, BoardLength, _).
alignedVert(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	LastIndex is BoardLength-(Size-1)*BoardDimension-1, %% 76=11*11-4*11-1
    Acc =< LastIndex,
	not(isPosEmpty(Board, Acc)),
	nth0(Acc, Board, Player),
	vertOfSize(Board, Acc, Player, 0, Size, BoardDimension),
	NewAcc is Acc + 1,
	NewAccCount is AccCount + 1,
	alignedVert(Board, NewAcc, Player, Size, TotalCount, NewAccCount, BoardLength, BoardDimension),
	!.
alignedVert(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	NewAcc is Acc + 1,
	alignedVert(Board, NewAcc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension),
	!.

alignedLeftDiag(_, BoardLength, _, _, TotalCount, TotalCount, BoardLength, _).
alignedLeftDiag(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	LastIndex is BoardLength-(Size-1)*BoardDimension-1,
    Acc =< LastIndex,
	Acc mod BoardDimension >= (Size-1),
	not(isPosEmpty(Board, Acc)),
	nth0(Acc, Board, Player),
	leftDiagOfSize(Board, Acc, Player, 0, Size, BoardDimension),
	NewAcc is Acc + 1,
	NewAccCount is AccCount + 1,
	alignedLeftDiag(Board, NewAcc, Player, Size, TotalCount, NewAccCount, BoardLength, BoardDimension),
	!.
alignedLeftDiag(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	NewAcc is Acc + 1,
	alignedLeftDiag(Board, NewAcc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension),
	!.

alignedRightDiag(_, BoardLength, _, _, TotalCount, TotalCount, BoardLength, _).
alignedRightDiag(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	LastIndex is BoardLength-(Size-1)*BoardDimension-1-(Size-1),
    Acc =< LastIndex, %%76-4
	RowLastIndex is BoardDimension-1-(Size-1),
    Acc mod BoardDimension =< RowLastIndex,
	not(isPosEmpty(Board, Acc)),
	nth0(Acc, Board, Player),
	rightDiagOfSize(Board, Acc, Player, 0, Size, BoardDimension),
	NewAcc is Acc + 1,
	NewAccCount is AccCount + 1,
	alignedRightDiag(Board, NewAcc, Player, Size, TotalCount, NewAccCount, BoardLength, BoardDimension),
	!.
alignedRightDiag(Board, Acc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension) :-
	NewAcc is Acc + 1,
	alignedRightDiag(Board, NewAcc, Player, Size, TotalCount, AccCount, BoardLength, BoardDimension),
	!.

%%%%% Check horizontal alignments
horiOfSize(Board, Index, Player, Acc, Size, _) :-
    checkConfig(Board, Index, Player, Acc, Size, 1).

%%%%% Check vertical alignments
vertOfSize(Board, Index, Player, Acc, Size, BoardDimension) :-
    checkConfig(Board, Index, Player, Acc, Size, BoardDimension).

%%%%% Check left diagonal alignments (top right - bottom left)
leftDiagOfSize(Board, Index, Player, Acc, Size, BoardDimension) :-
    Increment is BoardDimension - 1,
    checkConfig(Board, Index, Player, Acc, Size, Increment).

%%%%% Check right diagonal alignments (top left - bottom right)
rightDiagOfSize(Board, Index, Player, Acc, Size, BoardDimension) :-
    Increment is BoardDimension + 1,
    checkConfig(Board, Index, Player, Acc, Size, Increment).

%%%%% Check for alignments, direction is chosen by the last argument
checkConfig(_, _, _, Size, Size, _).
checkConfig(Board, Index, Player, Acc, Size, Increment) :-
    not(isPosEmpty(Board, Index)),
    nth0(Index, Board, Player),
    NewAcc is Acc + 1,
    NewIndex is Index + Increment,
    checkConfig(Board, NewIndex, Player, NewAcc, Size, Increment).
