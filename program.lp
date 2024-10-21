% Vrachtwagen, depot en klantdefinities
truck(t1).
depot(d1).
customer(c1).
customer(c2).

% Locaties
location(d1).
location(c1).
location(c2).

% Afstanden tussen locaties (in minuten)
distance(d1, c1, 30).
distance(c1, c2, 20).
distance(c2, d1, 40).

% Tijdvensters voor leveringen (in minuten)
time_window(c1, 60, 120).  % klant 1 verwacht levering tussen 60 en 120 minuten
time_window(c2, 90, 180).  % klant 2 verwacht levering tussen 90 en 180 minuten

% Tijdshorizon
time(0..300).  % Simuleer een tijdshorizon van 0 tot 300 minuten

% Initieel fluent: De vrachtwagen begint bij het depot op tijdstip 0
holds(at(t1, d1), 0).

% Action: Vrachtwagen verplaatst zich van locatie From naar locatie To
occurs(move(T, From, To), StartTime) :- 
    truck(T), location(From), location(To), time(StartTime),
    holds(at(T, From), StartTime), 
    distance(From, To, D), 
    EndTime = StartTime + D, 
    time(EndTime).

% Causal Law: Als een actie plaatsvindt, verandert de positie van de vrachtwagen
holds(at(T, To), EndTime) :- 
    occurs(move(T, From, To), StartTime), 
    distance(From, To, D), 
    EndTime = StartTime + D.

% State Constraint: De vrachtwagen kan slechts op één locatie tegelijk zijn
:- holds(at(T, L1), T2), holds(at(T, L2), T2), L1 != L2.

% Goal: Het doel is om alle klanten te leveren
goal(delivered(C)) :- customer(C).

% Fluent: De levering wordt als succesvol beschouwd wanneer het binnen het tijdsvenster is uitgevoerd
holds(delivered(C), T) :- 
    customer(C), holds(at(t1, C), T), 
    time_window(C, Min, Max), 
    Min <= T, T <= Max.

% Success Condition: Een levering is succesvol als het doel bereikt is
success(C) :- goal(delivered(C)), holds(delivered(C), _).

% Executability Condition: De vrachtwagen kan alleen bewegen als hij op de locatie is
occurs(move(T, From, To), StartTime) :- 
    holds(at(T, From), StartTime), 
    distance(From, To, D), 
    EndTime = StartTime + D, 
    time(EndTime).

% State Constraint: Elke klant moet op een bepaald moment geleverd worden
:- goal(delivered(C)), not holds(delivered(C), _).

% Minimalisatie van levertijden buiten het tijdsvenster (Penalty voor laat zijn)
penalty(C, Penalty) :- 
    holds(delivered(C), T), 
    time_window(C, _, Max), 
    Penalty = T - Max, 
    Penalty > 0.

% Optimalisatie: Minimaliseer de totale levertijd en penalties
#minimize { T : holds(delivered(C), T) ; Penalty : penalty(C, Penalty) }.

% Output regels
#show holds/2.
#show occurs/2.
#show success/1.
