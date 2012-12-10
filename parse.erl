-module(parse).
-compile(export_all).

lex(Program) ->
    Prog_Replace = re:replace(re:replace(Program, "[(]", " ( ", [global]), "[)]", " ) ", [global, {return, list}]),
    string:tokens(Prog_Replace, " ").
    
read(["("|Tail]) ->
    case read(Tail) of 
        {Done, ok} -> {list, Done};
        {Done, Remaining} ->
            {A, B} = read(Remaining),  
            {[{list, Done}] ++ A, B}
    end;
read([")"]) ->
    {[], ok};
read([")"|Tail]) ->
    {[], Tail};
read([H|Tail]) ->
    Token = 
        try list_to_integer(H) of X -> {num, X}
        catch Error:badarg -> 
            try list_to_float(H) of Y -> {num, Y}
            catch Error:badarg -> {str, H}
            end
        end,
    {A, B} = read(Tail),
    {[Token] ++ A, B}.
    
parse(Program) -> read(lex(Program)). 