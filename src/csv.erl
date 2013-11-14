-module(csv).
-compile([export_all]).


convert(B) ->
      B.
%%    BB = binary_to_list(B),
    
%%    try list_to_integer(BB)
%%    catch
%%        Error:Reason -> 
%%                  try list_to_float(BB)
%%                  catch 
%%                    Error:Reason -> B 
%%                  end 
%%    end.

readlines(FileName) ->
    {ok, Binary} = file:read_file(FileName),
    Binary.


parse_csv(B) -> [ list_to_tuple([ convert(E) || E <- binary:split(L,<<",">>,[global]) ])  
                                                                || L <- binary:split(B,<<"\n">>,[global])].


parse_line(B) ->
  %%io:put_chars(io_lib:print(B)),
  %%io:put_chars(io_lib:nl()),
  case B of
    <<"\"",Rest/binary>> -> [H,T] = binary:split(Rest,<<"\"">>,[]), [convert(H)|parse_line(T)];
    <<>>                 -> [];
    <<Rest/binary>>  -> case binary:split(Rest,<<",">>,[]) of
                              [<<>>,T] -> parse_line(T);
                              [H,T]    -> [convert(H)|parse_line(T)];
                              [H]      -> [convert(H)]
                            end
  end.

parse_csv_1(B) -> [ list_to_tuple(parse_line(L))  || L <- binary:split(B,<<"\n">>,[global])].

done_parse(R) -> [ convert(E) || E <- lists:reverse(R) ].

parse_line_stateful(not_in_string,<<"\"",Rest/binary>>,<<>>,Res)  -> parse_line_stateful(string,Rest,<<>>,Res);
parse_line_stateful(not_in_string,<<"\"",_/binary>>,_,_)          -> throw(wrong_format);

parse_line_stateful(not_in_string,<<>>,<<>>,Res)                  -> done_parse(Res);
parse_line_stateful(not_in_string,<<>>,Acc,Res)                   -> done_parse([Acc|Res]);

parse_line_stateful(not_in_string,<<",",Rest/binary>>,<<>>,Res)   -> parse_line_stateful(not_in_string,Rest,<<>>,Res);
parse_line_stateful(not_in_string,<<",",Rest/binary>>,Acc,Res)    -> parse_line_stateful(not_in_string,Rest,<<>>,[Acc|Res]);
parse_line_stateful(not_in_string,<<S:8,Rest/binary>> ,Acc,Res)   -> parse_line_stateful(not_in_string,Rest,<<Acc/binary,S:8>>,Res);



parse_line_stateful(string,<<"\"",Rest/binary>>,Acc,Res) -> parse_line_stateful(not_in_string,Rest,<<>>,[Acc|Res]);
parse_line_stateful(string,<<>>,_,_)                     -> throw(string_not_terminated);
parse_line_stateful(string,<<S:8,Rest/binary>>,Acc,Res)  -> parse_line_stateful(string,Rest,<<Acc/binary,S:8>>,Res).


parse_csv_2(B) -> [ list_to_tuple(parse_line_stateful(not_in_string,L,<<>>,[]))  || L <- binary:split(B,<<"\n">>,[global])].
