-module(csv).
-compile([export_all]).


convert(B) ->
    BB = binary_to_list(B),
    
    try list_to_integer(BB)
    catch
        Error:Reason -> 
                  try list_to_float(BB)
                  catch 
                    Error:Reason -> BB 
                  end 
    end.

readlines(FileName) ->
    {ok, Binary} = file:read_lines(FileName),
    Binary.


parse_csv(B) -> [ list_to_tuple([ convert(E) || E <- binary:split(L,<<",">>,[global]) ])  || L <- binary:split(B,<<"\n">>,[global])].

