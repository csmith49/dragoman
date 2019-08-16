module VarMap = CCMap.Make(Variable)

type t = int VarMap.t

(* access *)
let get row var = VarMap.get var row
let variables row = row
    |> VarMap.to_list
    |> CCList.map fst

(* construction *)
let singleton var idx = VarMap.singleton var idx
let of_list = VarMap.of_list
let to_list = VarMap.to_list

(* manipulation *)
let project row vars = vars
    |> CCList.map (fun var -> match get row var with
        | Some idx -> Some (var, idx)
        | _ -> None)
    |> CCList.all_some
    |> CCOpt.map of_list

let rename row assoc = VarMap.to_list row
    |> CCList.map (fun (var, idx) ->
        match CCList.assoc_opt ~eq:Variable.equal var assoc with
            | Some var' -> (var', idx)
            | _ -> (var, idx))
    |> of_list

let join left right = 
    let vars = (variables left) @ (variables right) in vars
        |> CCList.map (fun var -> 
            match get left var, get right var with
                | Some i, Some j -> if i = j then
                    Some (var, i) else None
                | Some i, None -> Some (var, i)
                | None, Some j -> Some (var, j)
                | _ -> None)
        |> CCList.all_some
        |> CCOpt.map of_list