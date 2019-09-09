type t

(* alias for modules *)
type caption = t

(* getters *)
val variables : t -> Horn.Variable.t list
val target_variable : t -> Horn.Variable.t
val conjuncts : t -> Horn.Conjunct.t list

(* uses *)
val apply : t -> Core.Scene.t -> Core.Thing.t list

(* printing *)
val to_string : t -> string

(* manipulation *)
val remap : t -> Horn.Variable.Mapping.t -> t
val canonicalize : ?base:string -> t -> t

(* comparisons *)
module PartialOrder : sig
    type t = [
        | `LEq
        | `GEq
        | `Eq
        | `Incomparable
    ]

    val compare : caption -> caption -> t
end