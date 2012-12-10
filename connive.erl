-module(connive).
-compile(export_all).

eval({list, [{str, "quote"}|X]}, Env) ->
    [T] = X, {T, Env};
    
eval({list, [{str, "if"}|X]}, Env) ->
    [Test, Conseq, Alt] = X,
    case eval(Test, Env) of
        {true, _} ->
            eval(Conseq, Env);
        {false, _} ->
            eval(Alt, Env)
    end;
    
eval({list, [{str, "set!"}|X]}, Env) ->  
    [{str, Var}, Exp] = X,
    {Value, _} = eval(Exp, Env),
    Env2 = dict:store(Var, Value, Env),
    {ok, Env2};

eval({list, [{str, "define"}|X]}, Env) -> 
    [{str, Var}, Exp] = X,
    {Value, _} = eval(Exp, Env),
    Env2 = dict:store(Var, Value, Env),
    {ok, Env2};
    
eval({list, [{str, "lambda"}|X]}, Env) ->
    io:format("~p~n", [X]),
    [{list, Vars}|ExpL] = X,
    [Exp] = ExpL,
    io:format("~p~n", [Vars]),
    Lambda = fun(Args) -> 
        Env2 = dict:merge(fun(A, _) -> A end, dict:from_list(lists:zip(Vars, Args)), Env),
        eval(Exp, Env2) end,
    {Lambda, Env};

eval({list, [{str, "begin"}|X]}, Env) ->
    [H|T] = X,
    case T of 
        [] -> {Value, Env2} = eval(H, Env), {Value, Env2};
        _ -> {_, Env2} =eval(H, Env), eval({list, [{str,"begin"}] ++ T}, Env2)
    end;

eval(X, Env) ->
    case X of 
        {num, Y} -> {Y, Env};
        {str, Y} -> 
            case dict:find(Y, Env) of 
                {ok, B} -> {B, Env};
                _ -> 
                    {Y, Env}
            end;
        {list, Y} ->
            case Y of 
                [{str, H}|T] ->
                    {ok, Fun} = dict:find(H, Env),
                    T2 = lists:map(fun(L) -> {Value, _} = eval(L, Env), Value end, T),
                    {Fun(T2), Env};
                [H|T] ->
                    {Fun, _} = eval(H, Env),
                    T2 = lists:map(fun(L) -> {This, _} = eval(L, Env), This end, T),
                    {Fun(T2), Env}
            end
    end.
        

build_global([], Dict) ->
    Dict;
build_global([H|T], Dict) ->
    [Var, Value] = H,
    Dict2 = dict:store(Var, Value, Dict),
    build_global(T, Dict2). 
    