type relation_key = string

module KeyMap = CCMap.Make(CCString)

type t = Relation.t KeyMap.t

let empty = KeyMap.empty

let add store key rel = KeyMap.add key rel store

let relations store = store |> KeyMap.to_list |> CCList.map fst

let relation store key = KeyMap.get key store

let of_list = KeyMap.of_list
let to_list = KeyMap.to_list

let print store =
    let left, right = 
        Variable.of_string "left", Variable.of_string "right" in
    let to_tbl rel = Table.of_relation rel left right |> CCOpt.get_exn in
    store
        |> to_list
        |> CCList.iter (fun (key, rel) ->
            Printf.printf "-{ %s }-\n%s\n"
                key
                (rel |> to_tbl |> Table.to_csv ~delimiter:", ")
        )