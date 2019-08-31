(* tables are of type T.t *)
(* we use variables as keys and integers as values *)
module T = Utility.Tbl.Make(Variable)(CCInt)

(* exposing the required type *)
type t = T.t

(* and the required functions that are taken straight from T *)
let empty = T.empty
let join_all = T.join_all
let to_csv = T.to_csv
let of_list = T.of_list
let equal = T.equal

(* Tbl doesn't give a mechanism for making tables from JSON, but we'll want to do so for testing *)
let of_json json = let module J = Utility.JSON in
    let keys = J.Parse.get "keys" (J.Parse.list Variable.of_json) json in
    let rows = J.Parse.get "rows" (J.Parse.list (J.Parse.list J.Literal.int)) json in
    match keys, rows with
        | Some keys, Some rows -> of_list keys rows
        | _ -> None