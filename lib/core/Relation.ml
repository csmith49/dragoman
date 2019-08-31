type index = int
type t = (index * index) list

let to_string ls = ls
    |> CCList.map (fun (x, y) -> "<" ^ (string_of_int x) ^ ", " ^ (string_of_int y) ^ ">")
    |> CCString.concat ", "

let of_map ls = CCList.mapi (fun i -> fun js ->
    CCList.map (fun j -> (i, j)) js) ls |> CCList.flatten
let of_json json = let module J = Utility.JSON in let open CCOpt.Infix in
    J.Parse.list (J.Parse.list J.Literal.int) json >|= of_map
