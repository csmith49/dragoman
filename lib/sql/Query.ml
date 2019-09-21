type t = string

let of_string s = s
let to_string s = s

let join l r = Printf.sprintf "(%s) JOIN (%s)" l r
let join_all qs = qs
    |> CCList.map (fun s -> "(" ^ s ^ ")")
    |> CCString.concat " JOIN "