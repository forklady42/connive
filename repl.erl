-module(repl).
-compile(export_all).
-import(parse).
-import(connive).

start() ->
    c:c(parse),
    c:c(connive),
    
    G = [["+", fun([A, B]) -> A + B end], ["-", fun([A, B]) -> A - B end],
         ["*", fun([A, B]) -> A * B end], ["/", fun([A, B]) -> A / B end],
         [">", fun([A, B]) -> A > B end], ["<", fun([A, B]) -> A < B end],
         [">=", fun([A, B]) -> A >= B end], ["<=", fun([A, B]) -> A =< B end],
         ["length", fun(A) -> length(A) end], ["true", fun(_) -> true end], 
         ["false", fun(_) -> false end]],
         
    Global = connive:build_global(G, dict:new()),
    run(Global).
    
run(Env) ->
    Exp = string:strip(io:get_line("connive> "), right, $\n),
    case Exp of
        "(exit)" -> ok;
        _ -> {Value, Env2} = connive:eval(parse:parse(Exp), Env),
            io:format("~p~n", [Value]),
            run(Env2)
    end. 