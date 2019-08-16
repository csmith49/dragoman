(* for optimization and usability purposes, we don't store rows *)
type internal_row = int list

(* instead, maintain indexing via a variable list *)
type t =  {
    rows : internal_row list;
    variables : Variable.t list;
}

(* access *)
let get tbl var =
    match CCList.find_idx (fun v -> v = var) tbl.variables with
        | Some (idx, _) -> Some (
            CCList.map (CCList.get_at_idx_exn idx) tbl.rows
        )
        | _ -> None

let variables tbl = tbl.variables

let irow_to_row tbl irow = irow
    |> CCList.map2 (fun v -> fun idx -> (v, idx)) tbl.variables
    |> Row.of_list
let rows tbl = tbl.rows |> CCList.map (irow_to_row tbl)

(* construction *)
let empty = {
    rows = [];
    variables = [];
}
let empty_with_variables vars = {
    empty with variables = vars;
}

let of_row row =
    let assoc = Row.to_list row in
    {
        rows = [CCList.map snd assoc];
        variables = CCList.map fst assoc;
    }

let add_row tbl row =
    match Row.project row tbl.variables with
        | Some row ->
            let irow = CCList.map snd (Row.to_list row) in
            Some {
                tbl with rows = irow :: tbl.rows;
            }
        | _ -> None

let of_list rows = match rows with
    | row :: [] ->
        Some (of_row row)
    | row :: rest ->
        let tbl = Some (of_row row) in
        let add stbl row = match stbl with
            | Some tbl -> add_row tbl row
            | _ -> None in
        CCList.fold_left add tbl rest
    | [] -> Some empty

(* manipulation *)
let project tbl vars = rows tbl
    |> CCList.map (fun r -> Row.project r vars)
    |> CCList.all_some
    |> CCOpt.flat_map of_list

let rename tbl assoc =
    let vars' = tbl.variables
        |> CCList.map (fun var ->
            match CCList.assoc_opt ~eq:Variable.equal var assoc with
                | Some var' -> var'
                | _ -> var) in 
    {
        tbl with variables = vars';
    }

let join left right =
    let rows = 
        CCList.join ~join_row:Row.join 
            (rows left) (rows right) in
    match rows |> of_list with
        | Some tbl -> tbl
        | None -> 
            let vars = (variables left) @ (variables right)
                |> CCList.uniq ~eq:Variable.equal in
            {
                variables = vars;
                rows = [];
            }

let join_all tbls = match tbls with
    | tbl :: [] -> tbl
    | tbl :: rest -> CCList.fold_left join tbl rest
    | [] -> empty

let filter tbl pred =
    let rows' = tbl.rows
        |> CCList.filter (fun irow ->
            irow |> irow_to_row tbl |> pred
        ) in
    {
        tbl with rows = rows';
    }

(* output *)
let irow_to_json irow = `List (CCList.map (fun i -> `Int i) irow)
let to_json tbl = `Assoc [
    ("keys", `List (CCList.map Variable.to_json tbl.variables)) ;
    ("rows" , `List (CCList.map irow_to_json tbl.rows))
]
(* print as csv *)
let to_string ?(delimiter=",") tbl =
    let header = tbl.variables |> CCList.map Variable.to_string |> CCString.concat delimiter in
    let rows = tbl.rows |> CCList.map (CCList.map string_of_int) |> CCList.map (CCString.concat delimiter) in
        CCString.concat "\n" (header :: rows)