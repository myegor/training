-module(problems).
-compile([export_all]).


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


s_helper([H|T],1,Acc) -> {reverse([H|Acc]),T}; 
s_helper([H|T],K,Acc) -> s_helper(T,K-1,[H|Acc]).

split(L,K) -> s_helper(L,K,[]).

s_length([],Acc) -> Acc;
s_length([_|T],Acc) -> s_length(T,1+Acc).

s_permute([],_,Acc) -> Acc;
s_permute(L,Len,Acc)  -> ID = random:uniform(Len), s_permute(delete(L,ID),Len-1,[find(L,ID)|Acc]).  

permute(L) -> s_permute(L,s_length(L,0),[]).


s_flatten([],Acc) -> Acc;
s_flatten([H|T],Acc) when is_list(H)-> s_flatten(T,s_flatten(H,Acc));
s_flatten([H|T],Acc) -> s_flatten(T,[H|Acc]).

flatten(L) -> reverse(s_flatten(L,[])). 


count([H|T],H,Acc) -> count(T,H,1+Acc);
count([],_,Acc)    -> Acc;
count([_|_],_,Acc) -> Acc.

rle_encode([],Acc) -> Acc;
rle_encode([H|T],Acc) -> 
						 case count(T,H,0) of
						 	0   -> rle_encode(T,[{H,1}|Acc]);
						 	Num -> rle_encode(element(2,split(T,Num)),[{H,Num+1}|Acc])
						 end.

encode(L) -> reverse(rle_encode(L,[])).

add_num(_,0,Acc) -> Acc;
add_num(S,K,Acc) -> add_num(S,K-1,[S|Acc]).

rle_decode([],Acc)        -> Acc;
rle_decode([{S,C}|T],Acc) -> rle_decode(T,add_num(S,C,Acc)).

decode(L) -> reverse(rle_decode(L,[])). 


