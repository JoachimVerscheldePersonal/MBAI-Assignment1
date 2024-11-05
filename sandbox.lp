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
fluent(delivered(C), defined):- customer(C).
% Actions:
action(move(T,V1,V2)):- truck(T), adj(V1,V2), V1 != V2.
% Closed world assumption:
-holds(F,I) :- fluent(F,inertial), not holds(F,I), step(I).

-occurs(A,I) :- action(A), not occurs(A,I), step(I).
% Causal laws:
holds(at(T,V2),I+1) :- occurs(move(T,V1,V2),I), adj(V1,V2), truck(T), step(I).
% State constraints:
% Truck can only be in one location at a time
:- holds(at(T, V1),I), holds(at(T, V2),I), truck(T), vertex(V1), vertex(V2), step(I), V1 != V2.
% a customer is delivered if the truck is at the customer's location
holds(delivered(C),I) :- holds(at(T,C),I), customer(C), truck(T), step(I).
holds(delivered(C), I+1) :- holds(delivered(C), I), step(I).
% Executability conditions
% Cannot move from a vertex when the truck is not there
:- occurs(move(T,V1,V2),I), not holds(at(T,V1),I), truck(T), vertex(V1), vertex(V2), step(I).
:- occurs(move(T,V1,V2),I), not adj(V1,V2), truck(T), step(I).

% Inertia axioms:
holds(F, I+1) :- holds(F,I),  not -holds(F,I+1), fluent(F,inertial), step(I).
-holds(F, I+1) :- -holds(F,I),  not holds(F,I+1), fluent(F,inertial), step(I).

% Start state
holds(at(t1,d1),0).
-holds(delivered(c1),0).
-holds(delivered(c2),0).

% occurs(move(t1,d1,v1),0).
% occurs(move(t1,v1,v2),1).
% occurs(move(t1,v2,v3),2).
% occurs(move(t1,v3,c2),3).
% occurs(move(t1,c2,v5),4).
% occurs(move(t1,v5,v6),5).
% occurs(move(t1,v6,c1),6).
% occurs(move(t1,c1,v9),7).
% occurs(move(t1,v9,v8),8).
% occurs(move(t1,v8,d1),9).
% occurs(move(t1,d1,v10),10).

% Goal
goal(I) :- step(I), holds(delivered(c1),I), holds(delivered(c2),I).

success :- goal(I), I<=n.

:- not success.

% Guess actions
{occurs(A,I): action(A)}=1 :- step(I), not goal(I), I < n.

% #show holds/2.
% #show delivered/1.
% #show goal/1.
% #show success/0.
#show occurs/2.

% % Goal
% goal :- customer(C) : delivered(C).
% % Guess actions
% % {occurs(move(T,V1,V2),I)}=1 :- truck(T), adj(V1,V2), step(I), not goal, I<n.
% success :- goal.
% :- not success.

% Output regels

%Action

% occurs(move(T, StartLoc, EndLoc)):- 
% % Causal Law: If an action occurs at time I, the position of the truck changes
% holds(at(T, EndLoc), EndTime):- occurs(move(T, StartLoc, EndLoc), StartTime),
%                                 holds(at(T, StartLoc), StartTime),
%                                 distance(StartLoc, EndLoc, D),
%                                 EndTime = StartTime + D I


% % Action: Vrachtwagen verplaatst zich van locatie From naar locatie To
% occurs(move(T, From, To), StartTime) :- 
%     truck(T), location(From), location(To), time(StartTime),
%     holds(at(T, From), StartTime), 
%     distance(From, To, D), 
%     EndTime = StartTime + D, 
%     time(EndTime).

% % Causal Law: Als een actie plaatsvindt, verandert de positie van de vrachtwagen
% holds(at(T, To), EndTime) :- 
%     occurs(move(T, From, To), StartTime), 
%     distance(From, To, D), 
%     EndTime = StartTime + D.

% % State Constraint: De vrachtwagen kan slechts op één locatie tegelijk zijn
% :- holds(at(T, L1), T2), holds(at(T, L2), T2), L1 != L2.

% % Goal: Het doel is om alle klanten te leveren
% goal(delivered(C)) :- customer(C).

% % Fluent: De levering wordt als succesvol beschouwd wanneer het binnen het tijdsvenster is uitgevoerd
% holds(delivered(C), T) :- 
%     customer(C), holds(at(t1, C), T), 
%     time_window(C, Min, Max), 
%     Min <= T, T <= Max.

% % Success Condition: Een levering is succesvol als het doel bereikt is
% success(C) :- goal(delivered(C)), holds(delivered(C), _).

% % Executability Condition: De vrachtwagen kan alleen bewegen als hij op de locatie is
% occurs(move(T, From, To), StartTime) :- 
%     holds(at(T, From), StartTime), 
%     distance(From, To, D), 
%     EndTime = StartTime + D, 
%     time(EndTime).

% % State Constraint: Elke klant moet op een bepaald moment geleverd worden
% :- goal(delivered(C)), not holds(delivered(C), _).

% % Minimalisatie van levertijden buiten het tijdsvenster (Penalty voor laat zijn)
% penalty(C, Penalty) :- 
%     holds(delivered(C), T), 
%     time_window(C, _, Max), 
%     Penalty = T - Max, 
%     Penalty > 0.

% % Optimalisatie: Minimaliseer de totale levertijd en penalties
% #minimize { T : holds(delivered(C), T) ; Penalty : penalty(C, Penalty) }.





