type relation_key = string
type t

val empty : t
val add : t -> relation_key -> Relation.t -> t
val relations : t -> relation_key list
val relation : t -> relation_key -> Relation.t option
val of_list : (relation_key * Relation.t) list -> t