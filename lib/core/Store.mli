(** Stores *)

(** Stores map relation keys to relations *)
type t

(** Relations are indexed in stores by strings *)
type relation_key = string

(** {1} Construction **)

(** [empty] is an empty store *)
val empty : t

(** [add store key rel] inserts a relation into a store *)
val add : t -> relation_key -> Relation.t -> t

(** [of_list assoc] constructs a store from an association list *)
val of_list : (relation_key * Relation.t) list -> t

(** {1} Access *)

(** [relations store] gives the list of keys used in the store *)
val relations : t -> relation_key list

(** [relation store key] retrieves the relation indexed by the given key *)
val relation : t -> relation_key -> Relation.t option

(** [to_list store] converts store back to an association list *)
val to_list : t -> (relation_key * Relation.t) list

(** {1} Utility *)

(** verbose store printing to standard out *)
val print : t -> unit