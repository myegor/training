-module(accountdb).
-compile([export_all]).



load(Filename) ->
    ets:insert(ets:new(adb,[set,named_table]),csv:parse_csv_1(csv:readlines(Filename))).

read(UserId) -> ets:lookup(adb,UserId).

write(BT) -> ets:insert(adb,BT).

dumpdb() -> ets:tab2list(adb).

io_flatten([])                     -> [];

io_flatten([H])   when is_list(H)  -> io_flatten(H); 
io_flatten([H|T]) when is_list(H)  -> io_flatten(H)++[<<"\n">>|io_flatten(T)];

io_flatten([H])                    -> [H];
io_flatten([H|T])                  -> [H,<<",">>|io_flatten(T)].


flatten(L) -> io_flatten(L). 

save(L) ->

     flatten([ tuple_to_list(V) ||  V <- L ]).