type index = int
type t = (index * index) list

val to_string : t -> string
val of_json : Yojson.Basic.t -> t option