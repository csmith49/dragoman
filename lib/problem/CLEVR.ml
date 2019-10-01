type t = {
    store : Core.Store.t;
    clause : Horn.Clause.t;
    expected : Core.Table.t option;
}

let scene_of_json json = let module J = Utility.JSON in
    let things = J.Parse.get
        "objects"
        (J.Parse.list (J.Parse.assoc_some_items Core.Value.of_json))
        json in
    let relationships = J.Parse.get
        "relationships"
        (J.Parse.assoc_some_items Core.Relation.of_json)
        json in
    match things, relationships with
        | Some things, Some relationships ->
            (* flatten the things-rep *)
            let flat_things = things
                |> CCList.mapi (fun i -> fun obj ->
                    let idx = `Int i in
                    CCList.map (fun (rel, v) -> (rel, (idx, v))) obj)
                |> CCList.flatten in
            (* project the first comp out to get the list of attributes *)
            let attribute_keys = flat_things
                |> CCList.map fst
                |> CCList.uniq ~eq:CCString.equal in
            (* group by the frst element and map to_relation over the snd *)
            let attributes = flat_things
                |> CCList.group_join_by
                    ~eq:CCString.equal
                    ~hash:CCString.hash
                    fst
                    attribute_keys
                |> CCList.map (
                    CCPair.map2 (fun tups -> tups |> CCList.map snd |> Core.Relation.of_list)
                ) in
            (* make the store *)
            Some (Core.Store.of_list (relationships @ attributes))
        | _ -> None

let expected_of_json json = let module J = Utility.JSON in
    let keys = J.Parse.get
        "keys"
        (J.Parse.list Core.Variable.of_json)
        json in
    let rows = J.Parse.get
        "rows"
        (J.Parse.list (J.Parse.list Core.Value.of_json))
        json in
    match keys, rows with
        | Some keys, Some rows -> Core.Table.of_list keys rows
        | _ -> None

let of_json json = let module J = Utility.JSON in
    let store = J.Parse.get "scene" scene_of_json json in
    let clause = J.Parse.get "clause" Horn.Clause.of_json json in
    let expected = J.Parse.get "_expected" expected_of_json json in
    match store, clause with
        | Some store, Some clause -> Some {
            store = store ;
            clause = clause;
            expected = expected;
        }
        | _ -> None