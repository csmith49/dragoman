(* version space algebra - an upward cone in the PO defined by captions *)
type t

(* combinations *)
val intersect : t -> t -> t
val union : t -> t -> t

(* constructions *)
val of_caption : Caption.t -> t

(* utility *)
val enumerate : t -> Caption.t list