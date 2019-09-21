type t = {
    target : Horn.Variable.t;
    clause : Horn.Clause.t;
}

type caption = t

(* getters *)
let variables caption =
    let clause_variables = Horn.Clause.variables caption.clause in
    if CCList.mem ~eq:Horn.Variable.equal caption.target clause_variables
        then clause_variables
        else caption.target :: clause_variables
let target_variable caption = caption.target
let conjuncts caption = Horn.Clause.conjuncts caption.clause

(* uses *)
let apply caption scene = match Horn.Clause.evaluate caption.clause scene with
    | Some tbl -> Horn.Table.get caption.target tbl
        |> CCOpt.get_or ~default:[]
        |> CCList.filter_map (Core.Scene.thing scene)
    | None -> []

(* printing *)
let to_string caption = 
    let conjuncts_rep = caption.clause
        |> Horn.Clause.conjuncts
        |> CCList.map Horn.Conjunct.to_string
        |> CCString.concat ", " in
    (Horn.Variable.to_string caption.target) ^ " <- " ^ conjuncts_rep

(* manipulation *)
let remap caption mapping = {
    target = Horn.Variable.Mapping.remap caption.target mapping;
    clause = Horn.Clause.remap caption.clause mapping;
}

let canonicalize ?(base="") caption =
    let mapping = caption
        |> variables
        |> CCList.mapi (fun i -> fun x ->
            let x' = Horn.Variable.of_indexed_rep base i in
            (x, x')
        ) in
    remap caption mapping

(* structural stuff *)

(* necessarily, a variable is connected to itself *)
(* helps with computing the transitive closure *)
let connected_variables caption variable =
    caption.clause
        |> Horn.Clause.conjuncts
        |> CCList.flat_map (fun conjunct ->
            let vars = Horn.Conjunct.variables conjunct in
            if CCList.mem ~eq:Horn.Variable.equal variable vars then vars else []
        )
let rec transitive_connected_variables caption variables =
    let variables = CCList.sort_uniq ~cmp:Horn.Variable.compare variables in
    let vars = variables
        |> CCList.flat_map (connected_variables caption)
        |> CCList.sort_uniq ~cmp:Horn.Variable.compare in
    if vars == variables then vars else transitive_connected_variables caption vars
let connected caption =
    let variables = CCList.sort_uniq ~cmp:Horn.Variable.compare (variables caption) in
    let reachable = transitive_connected_variables caption [caption.target] in
        variables == reachable

let size caption = CCList.length (Horn.Clause.conjuncts caption.clause)

(* comparisons *)
module PartialOrder = struct
    type t = [
        | `LEq
        | `GEq
        | `Eq
        | `Incomparable
    ]

    let embed_in_clause_wrt_map conjunct clause mapping =
        CCList.filter_map (fun conjunct' -> 
            Horn.Conjunct.equal_wrt_mapping mapping conjunct conjunct')
        clause

    let is_leq left right =
        let left = canonicalize ~base:"left" left in
        let right = canonicalize ~base:"right" right in
        let mappings = let module M = Horn.Variable.Mapping in [
            M.make_equal_in left.target right.target M.empty
        ] in
        let conjuncts = Horn.Clause.conjuncts left.clause in
        Horn.Clause.conjuncts right.clause
            |> CCList.fold_left (fun mappings -> fun conjunct ->
                CCList.flat_map (embed_in_clause_wrt_map conjunct conjuncts) mappings
            ) mappings
            |> fun b -> not (CCList.is_empty b)

    let compare left right =
        let leq = is_leq left right in
        let geq = is_leq right left in
        if leq && geq then `Eq else
        if leq then `LEq else
        if geq then `GEq else
            `Incomparable
end