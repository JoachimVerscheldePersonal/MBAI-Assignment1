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

% adjacent vertices
adj(V1,V2) :- vertex(V1), vertex(V2), edge(V1,V2).
% commutative property
adj(V1,V2) :- adj(V2,V1).

% Time windows for the deliveries at the customers
time_window(c1, 60, 120).  % customer 1 expectes the delivery between 60 and 120 minutes
time_window(c2, 90, 180).  % customer 2 expectes the delivery between 90 and 180 minutes

#const n = 300.
step(0..n).

% fluents
fluent(inertial, at(T, V)) :- truck(T), location(L), vertex(V).

% Closed world assumption
-holds(F,I) :- fluent(inertial, F), not holds(F,I), step(I).

% Inertia axioms:
hold(F, I+1) :- hold(F,I),  not -hold(F,I+1), fluent(inertial, F).
-hold(F, I+1) :- -hold(F,I), not hold(F,I+1), fluent(inertial, F).

% Causal laws
holds(at(T,V2),I+1):- occurs(move(T,V1,V2),I), V1 != V2,  adj(V1,V2), truck(T), step(I).
% State constraints
% Executability conditions

% Start state
holds(at(t1,d1),0).
occurs(move(t1,d1,v1),0).
% Truck has to keep moving
 
% % Action

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

% Output regels
#show holds/2.
#show occurs/2.
#show success/1.
