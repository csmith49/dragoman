type t
type index = int
type relation = string

(* json interface *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* for printing *)
val to_string : t -> string

(* standard access and stuff *)
val thing : t -> index -> Thing.t option
val relations : t -> relation list
val relation : t -> relation -> (index * index) list option

(* actually used accesses *)
val things : t -> Thing.t list
val things_idx : t -> (index * Thing.t) list