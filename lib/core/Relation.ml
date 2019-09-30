type t = (Value.t * Value.t) list

let to_string ls = ls
    |> CCList.map (fun (x, y) -> "<" ^ (Value.to_string x) ^ ", " ^ (Value.to_string y) ^ ">")
    |> CCString.concat ", "

let of_map ls = CCList.mapi (fun i -> fun js ->
    CCList.map (fun j -> (`Int i, j)) js) ls |> CCList.flatten
let of_json json = let module J = Utility.JSON in let open CCOpt.Infix in
    J.Parse.list (J.Parse.list Value.of_json) json >|= of_map

let to_list x = x
let of_list x = x