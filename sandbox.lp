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

% Adjacent vertices
adj(V1,V2) :- vertex(V1), vertex(V2), edge(V1,V2,_).
% Commutative property
adj(V1,V2) :- adj(V2,V1).

#const n = 10.
step(0..n).

% Fluents
fluent(at(T, V), inertial) :- truck(T), vertex(V).
fluent(delivered(C), inertial):- customer(C).
% Actions:
action(move(T,V1,V2)):- truck(T), adj(V1,V2), V1 != V2.
% Closed world assumption:
-holds(at(T,V),I) :- fluent(at(T,V),inertial), not holds(at(T,V),I), step(I).
-holds(delivered(C),I) :- fluent(delivered(C),inertial), not holds(delivered(C),I), step(I).
-occurs(A,I) :- action(A), not occurs(A,I), step(I).
% Causal laws:
holds(at(T,V2),I+1) :- occurs(move(T,V1,V2),I), adj(V1,V2), truck(T), step(I).
% State constraints:
% Truck can only be in one location at a time
V1 = V2 :- holds(at(T, V1),I), holds(at(T, V2),I), truck(T), vertex(V1), vertex(V2), step(I).
% a customer is delivered if the truck is at the customer's location
holds(delivered(C),I) :- holds(at(T,C),I), customer(C), truck(T), step(I).
holds(delivered(C), I+1) :- holds(delivered(C), I), step(I).
% Executability conditions
% Cannot move from a vertex when the truck is not there
:- occurs(move(T,V1,V2),I), not holds(at(T,V1),I), truck(T), vertex(V1), vertex(V2), step(I).
:- occurs(move(T,V1,V2),I), not adj(V1,V2), truck(T), step(I).

% Inertia axioms:
hold(F, I+1) :- hold(F,I),  not -hold(F,I+1), fluent(F,inertial).
-hold(F, I+1) :- -hold(F,I),  not hold(F,I+1), fluent(F,inertial).

% Start state
holds(at(t1,d1),0).
% occurs(move(t1,d1,v1),0).
% occurs(move(t1,v1,v2),1).
% occurs(move(t1,v2,v3),2).
% occurs(move(t1,v3,c2),3).
% occurs(move(t1,c2,v5),4).

% Goal
goal(I) :- step(I), customer(C) : holds(delivered(C),I).

% Guess actions
{occurs(move(T,V1,V2),I)}=1 :- truck(T), adj(V1,V2), step(I), not goal(I).
success(I) :- goal(I), step(I).
:- not success(I), step(I).

#show holds/2.
#show occurs/2.