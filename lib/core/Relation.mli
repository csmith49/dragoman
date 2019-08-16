type index = int
type t = (index * index) list

val of_json : Yojson.Basic.t -> t option