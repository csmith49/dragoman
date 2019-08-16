type 'a parser = Yojson.Basic.t -> 'a option

module Parse = struct
    let list parser json = match json with
        | `List ls -> CCList.map parser ls
            |> CCList.all_some
        | _ -> None
    let assoc parsers json = let open CCOpt.Infix in
        match json with
            | `Assoc ls -> CCList.map (fun (key, parser) -> 
                CCList.assoc_opt ~eq:CCString.equal key ls
                >>= parser
                >|= (fun v -> (key, v))) parsers
                |> CCList.all_some
            | _ -> None
end

let assoc json key = match json with
    | `Assoc ls ->
        CCList.assoc_opt ~eq:CCString.equal key ls
    | _ -> None

let string = function
    | `String s -> Some s
    | _ -> None
let int = function
    | `Int i -> Some i
    | _ -> None
let list = function
    | `List ls -> Some ls
    | _ -> None

