type t = Conjunct.t list

let of_json json = let module J = Utility.JSON in
    J.Parse.list Conjunct.of_json json

let to_json clause = `List (
    clause |> CCList.map Conjunct.to_json
)

let to_string clause = CCString.concat ", " (CCList.map Conjunct.to_string clause)

let evaluate ?(verbose=false) clause scene =
    let tables = CCList.map (fun c -> 
        let tbl = Conjunct.evaluate c scene in
        let _ = if verbose then print_endline ("Evaluating conjunct " ^ (Conjunct.to_string c) ^ ":") in
        let _ = match tbl with
            | Some tbl -> if verbose then print_endline ( (Table.to_csv tbl) ^ "\n")
            | _ -> print_endline "NO TABLE\n" in
        tbl
    ) clause in
    match CCList.all_some tables with
        | Some tables -> Some (Table.join_all tables)
        | _ -> None
