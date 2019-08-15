(* Cats are the categorical info stored by a thing *)
type t

(* We're easily able to convert them to/from json reps *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* and we have all the usual comparisons *)
val compare : t -> t -> int
val equal : t -> t -> bool
val hash : t -> int

(* string conversion for printing *)
val to_string : t -> string