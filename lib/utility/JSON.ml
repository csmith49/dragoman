type 'a parser = Yojson.Basic.t -> 'a option

module Parse = struct
    let get key parser json = match json with
        | `Assoc ls -> CCList.assoc_opt ~eq:CCString.equal key ls
            |> CCOpt.flat_map parser
        | _ -> None
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
    let assoc_items parser json =
        match json with
            | `Assoc ls -> CCList.map (fun (key, item) ->
                    match parser item with
                        | Some v -> Some (key, v)
                        | _ -> None
                ) ls
                |> CCList.all_some
            | _ -> None
    let assoc_some_items parser json =
        match json with
            | `Assoc ls -> CCList.filter_map (fun (key, item) ->
                    match parser item with
                        | Some v -> Some (key, v)
                        | _ -> None) ls
                |> CCOpt.return
            | _ -> None
end

module Literal = struct
    let string = function
        | `String s -> Some s
        | _ -> None
    let int = function
        | `Int i -> Some i
        | _ -> None
end