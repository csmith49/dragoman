type t = {
    scene : Core.Scene.t;
    clause : Horn.Clause.t;
    expected : Core.Table.t option;
}

val of_json : Yojson.Basic.t -> t option