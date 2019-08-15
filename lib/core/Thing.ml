type attribute = string
let wanted : attribute -> bool = fun str ->
    CCList.mem ~eq:(CCString.equal) str [
        "size" ; "color" ; "shape" ; "material"
    ]

module AttrMap = CCMap.Make(CCString)

type t = Cat.t AttrMap.t

let of_json = function
    | `Assoc ls -> ls
        |> CCList.map (fun (k, v) ->
            if wanted k then match Cat.of_json v with
                | Some c -> Some (k, c)
                | _ -> None
            else None)
        |> CCList.all_some
        |> CCOpt.map (AttrMap.of_list)
    | _ -> None

let to_json thing = `Assoc (thing
    |> AttrMap.map (Cat.to_json)
    |> AttrMap.to_list)

let compare = AttrMap.compare (Cat.compare)
let equal = AttrMap.equal (Cat.equal)
let hash = CCHash.poly

let to_string _ = "THING"

let attributes thing = thing
    |> AttrMap.to_list
    |> CCList.map fst
let attribute thing attr = AttrMap.find_opt attr thing