#hide.
#show top/1.
#show parse/2.
#show parameter/2.
#show parameter/3.
#show state_vertex/3.
#show state_edge/2.

node(leaf(1..v)).
node(renaming(1..r)).
node(connecting(1..c)).
node(union(1..u)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  creating the parse tree of the formula
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binary(renaming(X)) :- node(renaming(X)).
binary(connecting(X)) :- node(connecting(X)).
incoming(union(X)) :- node(union(X)).
incoming(N) :- binary(N).

1 { parse(M, N) : M != N : incoming(N) } 1 :- node(M), M != connecting(c).

:- node(leaf(N)), not 1 { parse(leaf(N),union(X)) : node(union(X)) } 1.

:- binary(N), not 1 { parse(M,N) : node(M) } 1.
:- node(union(X)), not 2 { parse(M,union(X)) : node(M) } 2.

% there is only one top node
top(connecting(c)).

%% all nodes are reachable from top
%reachable(N) :- top(N). 
%reachable(M) :- parse(M,N), reachable(N). 
%:- node(N), not reachable(N). 

% break symmetries of descendent node ids
desc(M,N) :- parse(M,N), incoming(M).
desc(M,O) :- desc(M,N), parse(N,O).

:- desc(renaming(X), renaming(Y)), X > Y. 
:- desc(connecting(X), connecting(Y)), X > Y. 
:- desc(union(X), union(Y)), X > Y. 

% restrict to non repeating connections

:- parse(connecting(X), connecting(Y)), X < Y,
   parameter(connecting(X),A,B), parameter(connecting(Y),A,B). 

:- node(renaming(X)), node(renaming(Y)),  X < Y,
   parse(renaming(X), renaming(Y)),
   parameter(renaming(X),A,B), parameter(renaming(Y),A,B). 

:- node(renaming(X)), node(renaming(Y)),  X < Y,
   parse(renaming(X), renaming(Y)),
   parameter(renaming(X),A,B), parameter(renaming(Y),B,A). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  defining the operations and state on each node in the parse tree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label(1..l).

1 { parameter(leaf(X),I) : label(I) } 1 :- node(leaf(X)).
1 { parameter(connecting(X),I,J) : I < J : label(I;J) } 1 :- node(connecting(X)).
1 { parameter(renaming(X),I,J) : I != J : label(I;J) } 1 :- node(renaming(X)).

% break symmetry on choosing label

%:- parameter(leaf(1),1).

% initial state

state_vertex(leaf(V),V,L) :- parameter(leaf(V),L).

state_vertex(N,V) :- state_vertex(N,V,_).
:- not state_vertex(connecting(c),V), V = 1..v. 

% state update: union

state_vertex(union(X),V,L) :- parse(M,union(X)), state_vertex(M,V,L).
 
% state update: renaming

state_vertex(renaming(X),V,LL) :- 
    parse(M,renaming(X)), 
    state_vertex(M,V,L),
    parameter(renaming(X),L,LL).

state_vertex(renaming(X),V,L) :- 
    parse(M,renaming(X)), 
    state_vertex(M,V,L),
    parameter(renaming(X),LL,_),
    LL != L.

% state update: connecting

state_vertex(connecting(X),V,L) :- 
    parse(M,connecting(X)), 
    state_vertex(M,V,L).

state_edge(V11,V22) :- 
    parse(M,connecting(X)),
    state_vertex(M,V1,L1),
    state_vertex(M,V2,L2),
    parameter(connecting(X),L1,L2),
    mm(V1,V2,V11,V22).

mm(X,Y,X,Y) :- node(leaf(X)), node(leaf(Y)), X < Y.
mm(X,Y,Y,X) :- node(leaf(X)), node(leaf(Y)), X > Y.

% never add edges that dont exist in the final graph

:- state_edge(V,W), not edge(V,W).

% definition of final state: every edge needs to be created

:- edge(V,W), not state_edge(V,W).
%found(V,W) :- edge(V,W), state_edge(V,W).

%#maximize { found(_,_) } .
