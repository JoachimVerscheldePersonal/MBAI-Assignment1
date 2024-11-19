% Truck, depot and customers
truck(t1).
depot(d1).
customer(c1;c2).

% Vertices
vertex(d1;c1;c2;v1;v2;v3;v4;v5;v6;v7;v8;v9;v10).

% Weighted edges
edge(d1,v1,38).
edge(d1,v10,65).
edge(d1,v8,40).
edge(v1,v2,50).
edge(v2,v3,60).
edge(v2,v7,30).
edge(v3,v4,38).
edge(v3,c2,40).
edge(c2,v5,80).
edge(v5,v4,35).
edge(v5,v7,90).
edge(v5,v6,75).
edge(v6,v7,65).
edge(v6,c1,39).
edge(c1,v7,80).
edge(c1,v9,60).
edge(v9,v8,40).
edge(v9,v10,60).
edge(v8,v7,40).
edge(v8,d1,40).

% Undirected graph / commutative property
edge(V1,V2,D) :- edge(V2,V1,D).

% Adjacent vertices
adj(V1,V2) :- vertex(V1), vertex(V2), edge(V1,V2,_).

#const n = 10.
step(0..n).

%Distance
traveled_distance(T,I) :- truck(T), step(I).

% Fluents
fluent(at(T, V), inertial) :- truck(T), vertex(V).
fluent(delivered(C), defined):- customer(C).
% Actions:
action(move(T,V1,V2)):- truck(T), adj(V1,V2).
% Closed world assumption:
-holds(F,I) :- fluent(F,inertial), not holds(F,I), step(I).

-occurs(A,I) :- action(A), not occurs(A,I), step(I).
% Causal laws:
holds(at(T,V2),I+1) :- occurs(move(T,V1,V2),I), adj(V1,V2), truck(T), step(I).
% Define the distance of each move action at step I
move_distance(T, I, D) :- occurs(move(T, V1, V2), I), edge(V1, V2, D).

% State constraints:
% Truck can only be in one location at a time
:- holds(at(T, V1),I), holds(at(T, V2),I), truck(T), vertex(V1), vertex(V2), step(I), V1 != V2.
% a customer is delivered if the truck is at the customer's location
holds(delivered(C),I) :- holds(at(T,C),I), customer(C), truck(T), step(I).
holds(delivered(C), I+1) :- holds(delivered(C), I), step(I).

% Executability conditions
% Cannot move from a vertex when the truck is not there
:- occurs(move(T,V1,V2),I), not holds(at(T,V1),I), truck(T), vertex(V1), vertex(V2), step(I).

% Inertia axioms:
holds(F, I+1) :- holds(F,I),  not -holds(F,I+1), fluent(F,inertial), step(I).
-holds(F, I+1) :- -holds(F,I),  not holds(F,I+1), fluent(F,inertial), step(I).

% Start state
holds(at(t1,d1),0).
-holds(delivered(c1),0).
-holds(delivered(c2),0).

total_distance(TotalD) :- TotalD = #sum { D, I,T : move_distance(T,I,D) }.
% This is the same but without the move_distance predicate, and a lot less performant
% total_distance(TotalD) :- TotalD = #sum { D, I,T : holds(at(T,V1),I), holds(at(T,V2),I+1), edge(V1,V2,D) }.

% Goal
goal(I) :- step(I), holds(delivered(c1),I), holds(delivered(c2),I).
success :- goal(I), I<=n.
:- not success.

% Guess actions
{occurs(A,I): action(A)}=1 :- step(I), not goal(I), I < n.

#show holds/2.
#show occurs/2.
#show total_distance/1.
#show move_distance/3.

#minimize {TotalD: total_distance(TotalD)}.

