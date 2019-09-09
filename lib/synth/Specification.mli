type t

type input = Core.Scene.t
type output = Core.Thing.t

type example = input * output

val positive : t -> example list
val negative : t -> example list