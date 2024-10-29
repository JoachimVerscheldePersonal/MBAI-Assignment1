block(b0;b1;b2;b3;b4;b5;b6;b7).

location(X) :- block(X).
location(t).

#const n = 2.
step(0..n).

fluent(on(B,L)) :- block(B), location(L).
action(put(B,L)):- block(B), location(L), B != L.

holds(on(b0,t),0).
holds(on(b3,b0),0).
holds(on(b2,b3),0).
holds(on(b1,t),0).
holds(on(b4,b1),0).
holds(on(b5,t),0).
holds(on(b6,b5),0).
holds(on(b7,b6),0).

-holds(on(B,L),I) :- fluent(on(B,L),_), not holds(on(B,L),I), step(I).
holds(on(B,L),I+1) :- occurs(put(B,L),I), I<n.