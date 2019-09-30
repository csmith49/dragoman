type t = (Index.t * Index.t) list

let to_string ls = ls
    |> CCList.map (fun (x, y) -> "<" ^ (Index.to_string x) ^ ", " ^ (Index.to_string y) ^ ">")
    |> CCString.concat ", "

let of_map ls = CCList.mapi (fun i -> fun js ->
    CCList.map (fun j -> (Index.of_int i, j)) js) ls |> CCList.flatten
let of_json json = let module J = Utility.JSON in let open CCOpt.Infix in
    J.Parse.list (J.Parse.list Index.of_json) json >|= of_map

let to_list x = x
let of_list x = x