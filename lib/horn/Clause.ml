type t = Conjunct.t list

let of_json json = let module J = Utility.JSON in
    J.Parse.list Conjunct.of_json json

let to_json clause = `List (
    clause |> CCList.map Conjunct.to_json
)

let to_string clause = CCString.concat ", " (CCList.map Conjunct.to_string clause)

let evaluate clause scene =
    let tables = CCList.map (fun c -> Conjunct.evaluate c scene) clause in
    match CCList.all_some tables with
        | Some tables -> Some (Table.join_all tables)
        | _ -> None
