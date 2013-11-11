-module(problems).
-compile([export_all]).
-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").


r_helper([],Acc) -> Acc;
r_helper([H|T],Acc) -> r_helper(T,[H|Acc]).

reverse(L) -> r_helper(L,[]).

palindrome(X) -> X == reverse(X).

find([],_) -> [];
find([H|_],1) -> H;
find([_|T],K) when K > 1 -> find(T,K-1).

 
d_helper([_|T],1,Acc)  -> d_helper(T,0,Acc);
d_helper([H|T],K,Acc)  -> d_helper(T,K-1,[H|Acc]);
d_helper([],_,Acc)     -> Acc.

delete(L,K) -> reverse(d_helper(L,K,[])).

s_helper(L,0,_)       -> {[],L};
s_helper([H|T],1,Acc) -> {reverse([H|Acc]),T}; 
s_helper([H|T],K,Acc) -> s_helper(T,K-1,[H|Acc]).

split(L,K) -> s_helper(L,K,[]).

s_length([],Acc) -> Acc;
s_length([_|T],Acc) -> s_length(T,1+Acc).

s_permute([],_,Acc) -> Acc;
s_permute(L,Len,Acc)  -> 
	ID = random:uniform(Len), 
	s_permute(delete(L,ID),Len-1,[find(L,ID)|Acc]).  

permute(L) -> s_permute(L,s_length(L,0),[]).


s_flatten([],Acc) -> Acc;
s_flatten([H|T],Acc) when is_list(H)-> s_flatten(T,s_flatten(H,Acc));
s_flatten([H|T],Acc) -> s_flatten(T,[H|Acc]).

flatten(L) -> reverse(s_flatten(L,[])). 


rle_encode([],Acc)            -> Acc;
rle_encode([H|T],[{H,C1}|T1]) -> rle_encode(T,[{H,C1+1}|T1]);
rle_encode([H|T],[H|T1])      -> rle_encode(T,[{H,2}|T1]);
rle_encode([H|T],Acc)         -> rle_encode(T,[H|Acc]).


encode(L) -> reverse(rle_encode(L,[])).

rle_decode([],Acc)        -> Acc;
rle_decode([{S,1}|T],Acc) -> rle_decode(T,[S|Acc]);
rle_decode([{S,C}|T],Acc) -> rle_decode([{S,C-1}|T],[S|Acc]);
rle_decode([S|T],Acc)     -> rle_decode(T,[S|Acc]).


decode(L) -> reverse(rle_decode(L,[])). 


prop_delete() ->
    ?FORALL({X,L}, {integer(),list(integer())},
        not lists:member(X, lists:delete(X, L))).


problems_test() -> 
	?assertEqual(1,1),
    ?assertEqual([3,2,1],reverse([1,2,3])),
	?assertError(badarg,erlang:round(abc)).
    ?assertEqual([],proper:module(?MODULE, [{to_file, user},{numtests, 1000}])).