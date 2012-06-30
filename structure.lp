%% test case 1 complete graph P_4
%#const v = 4. % number of verticies
%#const r = 2. % number of renamings
%#const c = 3. % number of connections
%#const u = 3. % number of unions
%#const l = 2. % number of labels
%
%edge(1,2).
%edge(1,3).
%edge(1,4).
%edge(2,3).
%edge(2,4).
%edge(3,4).

% test case 2: grid of 2x3
%
#const v = 6. % number of verticies
#const r = 5. % number of renamings
#const c = 5. % number of connections
#const u = 5. % number of unions
#const l = 2. % number of labels

edge(1,2).
edge(2,3).
edge(4,5).
edge(5,6).
edge(1,4).
edge(2,5).
edge(3,6).

%% test case 3: see example in "Edge dominating set and colorings on graphs with fixed  clique-width"
%#const v = 8. % number of verticies
%#const r = 2. % number of renamings
%#const c = 7. % number of connections
%#const u = 7. % number of unions
%#const l = 3. % number of labels
%
%edge(1,2).
%edge(2,3).
%edge(3,4).
%edge(5,6).
%edge(6,7).
%edge(7,8).
%edge(2,6).
%edge(2,7).
%edge(3,6).
%edge(3,7).

#hide.
#show top/1.
#show parse/2.
#show parameter/2.
#show parameter/3.
#show state_vertex/3.
#show state_edge/3.

node(leaf(1..v)).
node(renaming(1..r)).
node(connecting(1..c)).
node(union(1..u)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  creating the parse tree of the formula
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

incoming(union(N)) :- node(union(N)).
incoming(renaming(N)) :- node(renaming(N)).
incoming(connecting(N)) :- node(connecting(N)).

0 { parse(M, N) : incoming(N) } 1 :- node(M).

:- incoming(N), parse(N,N).

:- node(leaf(N)), not 1 { parse(leaf(N),M) } 1.

:- node(renaming(N)), not 1 { parse(M,renaming(N)) : node(M) } 1.
:- node(connecting(N)), not 1 { parse(M,connecting(N)) : node(M) } 1.
:- node(union(N)), not 2 { parse(M,union(N)) : node(M) } 2.

% there is only one top node
top(N) :- node(N), { parse(N,M) : node(M) } 0. 
:- not 1 {top(N) : node(N) } 1.

% all nodes are reachable from top
reachable(N) :- top(N). 
reachable(M) :- parse(M,N), reachable(N). 
:- node(N), not reachable(N). 

% break symmetries of descendent node ids
desc(M,N) :- parse(M,N), incoming(M).
desc(M,O) :- desc(M,N), parse(N,O).

:- desc(renaming(X), renaming(Y)), X > Y. 
:- desc(connecting(X), connecting(Y)), X > Y. 
:- desc(union(X), union(Y)), X > Y. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  defining the operations and state on each node in the parse tree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label(1..l).

1 { parameter(leaf(X),I) : label(I) } 1 :- node(leaf(X)).
1 { parameter(connecting(X),I,J) : I < J : label(I;J) } 1 :- node(connecting(X)).
1 { parameter(renaming(X),I,J) : I != J : label(I;J) } 1 :- node(renaming(X)).

% initial state

state_vertex(leaf(V),V,L) :- parameter(leaf(V),L).

% frame axiom: edges are always passed on
state_edge(N,V,W) :- parse(M,N), state_edge(M,V,W).

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

state_edge(connecting(X),V1,V2) :- 
    parse(M,connecting(X)),
    state_vertex(M,V1,L1),
    state_vertex(M,V2,L2),
    parameter(connecting(X),L1,L2),
    V1 < V2. 

state_edge(connecting(X),V2,V1) :- 
    parse(M,connecting(X)),
    state_vertex(M,V1,L1),
    state_vertex(M,V2,L2),
    parameter(connecting(X),L1,L2),
    V1 > V2. 

% never add edges that dont exist in the final graph

:- state_edge(_,V,W), not edge(V,W).

% definition of final state: every edge needs to be created

:- top(N), edge(V,W), not state_edge(N,V,W).
