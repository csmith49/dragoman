open CCOpt.Infix

type t = {
    scene : Core.Scene.t;
    clause : Horn.Clause.t;
}

let of_json json = let module J = Utility.JSON in
    let scene = J.assoc json "scene" >>= Core.Scene.of_json in
    let clause = J.assoc json "clause" >>= Horn.Clause.of_json in
    match scene, clause with
        | Some scene, Some clause -> Some { scene = scene ; clause = clause }
        | _ -> None