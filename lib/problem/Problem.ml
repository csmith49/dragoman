type t = {
    scene : Core.Scene.t;
    clause : Horn.Clause.t;
    expected : Core.Table.t option;
}

let of_json json = let module J = Utility.JSON in
    let scene = J.Parse.get "scene" Core.Scene.of_json json in
    let clause = J.Parse.get "clause" Horn.Clause.of_json json in
    let expected = J.Parse.get "_expected" Core.Table.of_json json in
    match scene, clause with
        | Some scene, Some clause -> Some { scene = scene ; clause = clause ; expected = expected }
        | _ -> None