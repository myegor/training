-module(csv).
-compile([export_all]).


convert(B) ->
    BB = binary_to_list(B),
    
    try 
        list_to_integer(BB) 
    catch
        Exception:Reason -> 
                  try 
                        list_to_float(BB)  
                  catch 
                    Exception:Reason -> BB 
                  end 
    end.

readlines(FileName) ->
    {ok, Binary} = file:read_lines(FileName),
    Binary.


convert_string(B) -> [ list_to_tuple([ convert(E) || E <- binary:split(L,<<",">>,[global]) ])  || L <- binary:split(B,<<"\n">>,[global])].

