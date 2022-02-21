:- consult('data.pl').
:- op(200, xfy, of).

% N = 12
% Task 3: mother-in-law (свекровь) predicate

wife2(X, Y) :-  male(X), female(Y), child(Z, X), child(Z, Y).
father(M, C) :- child(C, M), male(M).
mother(W, C) :- child(C, W), female(W).
wife(W, M) :- female(W), have_child(W, M).
husband(M, W) :- female(W), have_child(W, M).
have_child(W, M) :- child(C, W), father(M, C), !.
mother_in_law(B, A) :- female(A), have_child(A, Z), female(B), child(Z, B).
% with repetitions
mother_in_law2(B, A) :- female(A), child(C, A), child(C, M), male(M), mother(B, M).


% Task 4

common_father(A, B) :- child(A, F), child(B, F), male(F), A \= B.
son(C, P) :- child(C, P), male(C).
daughter(C, P) :- child(C, P), female(C).
brother(A, B) :- common_father(A, B), male(A).
sister(A, B) :- common_father(A, B), female(A).

relation('father', M, C) :- father(M, C).
relation('mother', F, C) :- mother(F, C).
relation('son', C, P) :- son(C, P).
relation('daughter', C, P) :- daughter(C, P).
relation('brother', A, B) :- brother(A, B).
relation('sister', A, B) :- sister(A, B).

format(A of B, [A|C]) :- format(B, C).
format(A, [A]).

move(A, B) :- child(A, B).
move(A, B) :- child(B, A).
move(A, B) :- sister(A, B).
move(A, B) :- brother(A, B).

for(1).
for(M):- for(N), (N < 6 -> M is N+1; !, fail).

search_id(Path, A, B, N) :- N = 1, relation(Type, A, B), Path = [Type].
search_id(Path, A, B, N) :- N > 1, move(A, C), N1 is N - 1, search_id(Res, C, B, N1), relation(Type, A, C), append([Type], Res, Path).

relative(Res, A, B) :- var(Res), for(N), N < 6, search_id(Path, A, B, N), B \= A, format(Res, Path).
relative(Res, A, B) :- nonvar(Res), format(Res, Path), length(Path, N), search_id(Path, A, B, N), B \= A.

% Task 5

parse(Type, Rel, A, B) --> question(Type), main(Type, Rel, A, B), [?].

% Who are parents of A?
question(who) --> [who], [are].

% Who is sister of A?
question(who) --> [who], [is].

% What relationships are between A and B?
question(relationships) --> [what], word, [are].

% How many sisters does A have?
question(how) --> [how], [many].

word --> [X], {member(X, [relationships, relations])}.

main(who, Rel, A, _) --> name(Rel), [of], name(A).
main(relationships, _, A, B) --> [between], name(A), [and], name(B).
main(how, Rel, A, _)  --> name(Rel), [does], name(A), [have].

% Coping with english articles
name(A) --> [B], [A], {member(B, [the, a])}, !.
name(A) --> [A].

correct_rel(A, B) :- (A = sisters, B = sister); (A = brothers, B = brother); (A = sons, B = son); (A = daughters, B = daughter); B = A.

ans(who, Rel, A, B, Res) :- (Rel = parents, relative('father', Res, A), relative('mother', B, A)); correct_rel(Rel, Relation), relative(Relation, Res, A).
ans(relationships, _, A, B, Res) :- relative(Res, A, B).
ans(how, Rel, A, _, Res) :- Rel \= children, correct_rel(Rel, Relation), findall(B, relative(Relation, B, A), L), length(L, Res), !.
ans(how, _, A, _, Res) :- findall(B, child(B, A), L), length(L, Res).

ask(List, Res) :- parse(Type, Relation, A, B, List, []), ans(Type, Relation, A, B, Res).
ask(List, Res1, Res2) :- parse(Type, Relation, A, B, List, []), ans(Type, Relation, A, B, Res1), Res2 = B.