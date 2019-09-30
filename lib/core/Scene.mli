type t
type relation_key = string

(* json interface *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* for printing *)
val to_string : t -> string

(* standard access and stuff *)
val thing : t -> Index.t -> Thing.t option
val relations : t -> relation_key list
val relation : t -> relation_key -> Relation.t option

(* actually used accesses *)
val things_idx : t -> (Index.t * Thing.t) list

(* construction and manipulation *)
val empty : t
val add_thing : t -> Index.t -> Thing.t -> t
val add_relation : t -> relation_key -> Relation.t -> t

val add_attribute_to_thing : t -> Index.t -> Thing.attribute -> Cat.t -> t