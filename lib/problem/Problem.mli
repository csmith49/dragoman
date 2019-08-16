type t = {
    scene : Core.Scene.t;
    clause : Horn.Clause.t;
}

val of_json : Yojson.Basic.t -> t option