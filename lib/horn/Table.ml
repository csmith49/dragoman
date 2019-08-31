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
