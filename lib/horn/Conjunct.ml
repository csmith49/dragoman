type t =
    | Relate of Core.Scene.relation * Variable.t * Variable.t
    | Select of Core.Thing.attribute * Core.Cat.t * Variable.t

(* getters *)
let variables = function
    | Relate (_, l, r) -> [l ; r]
    | Select (_, _, x) -> [x]

(* manipulation *)
let remap conjunct mapping = match conjunct with
    | Relate (r, x, y) ->
        Relate (r, Variable.Mapping.remap x mapping, Variable.Mapping.remap y mapping)
    | Select (a, c, x) ->
        Select (a, c, Variable.Mapping.remap x mapping)

(* to and from json *)
let relate_of_json json = let module J = Utility.JSON in
    let relation = J.Parse.get "relation" J.Literal.string json in
    let left = J.Parse.get "left" Variable.of_json json in
    let right = J.Parse.get "right" Variable.of_json json in
    match relation, left, right with
        | Some rel, Some l, Some r -> Some (Relate (rel, l, r))
        | _ -> None

let select_of_json json = let module J = Utility.JSON in
    let attribute = J.Parse.get "attribute" J.Literal.string json in
    let value = J.Parse.get "value" Core.Cat.of_json json in
    let variable = J.Parse.get "variable" Variable.of_json json in
    match attribute, value, variable with
        | Some attr, Some v, Some x -> Some (Select (attr, v, x))
        | _ -> None

let of_json json = let module J = Utility.JSON in
    match J.Parse.get "kind" J.Literal.string json with
        | Some s when s = "relate" -> relate_of_json json
        | Some s when s = "select" -> select_of_json json
        | _ -> None

let to_json = function
    | Relate (rel, x, y) ->
        `Assoc [
            ("kind", `String "relate");
            ("relation", `String rel);
            ("left", Variable.to_json x);
            ("right", Variable.to_json y)
        ]
    | Select (attr, value, x) ->
        `Assoc [
            ("kind", `String "select");
            ("attribute", `String attr);
            ("value", Core.Cat.to_json value);
            ("variable", Variable.to_json x)
        ]

let to_string = function
    | Relate (rel, x, y) ->
        rel ^ "(" ^ (Variable.to_string x) ^ ", " ^ (Variable.to_string y) ^ ")"
    | Select (attr, value, x) ->
        (Variable.to_string x) ^ "." ^ attr ^ " = " ^ (Core.Cat.to_string value)


(* equality and the like *)
let equal left right = match left, right with
    | Relate (rel_l, x_l, y_l), Relate (rel_r, x_r, y_r) ->
        (rel_l == rel_r) && (Variable.equal x_l x_r) && (Variable.equal y_l y_r)
    | Select (a_l, val_l, x_l), Select (a_r, val_r, x_r) ->
        (a_l == a_r) && (Core.Cat.equal val_l val_r) && (Variable.equal x_l x_r)
    | _ -> false

let equal_wrt_mapping mapping left right = match left, right with
    | Relate (rel_l, x_l, y_l), Relate (rel_r, x_r, y_r) when rel_l == rel_r ->
        Some (mapping
            |> Variable.Mapping.make_equal_in x_l x_r
            |> Variable.Mapping.make_equal_in y_l y_r)
    | Select (a_l, val_l, x_l), Select (a_r, val_r, x_r) when a_l == a_r ->
        if not (Core.Cat.equal val_l val_r) then None else
        Some (mapping |> Variable.Mapping.make_equal_in x_l x_r)
    | _ -> None

(* table construction *)
let evaluate conjunct scene = match conjunct with
    (* CASE 1 - a relation where x and y are the same *)
    | Relate (rel, x, y) when Variable.equal x y ->
        begin match Core.Scene.relation scene rel with
            | Some ls -> ls
                |> CCList.filter_map
                    (fun (i, j) -> if i == j then Some [i] else None)
                |> Table.of_list [x]
            | _ -> Some (Table.empty [x]) end
    (* CASE 2 - a relation where x and y are distinct variables *)
    | Relate (rel, x, y) ->
        begin match Core.Scene.relation scene rel with
            | Some ls -> ls
                |> CCList.map (fun (i, j) -> [i ; j])
                |> Table.of_list [x ; y]
            | _ -> Some (Table.empty [x]) end
    (* CASE 3 - selection via attribute *)
    | Select (attr, value, x) ->
        let rows = Core.Scene.things_idx scene
            |> CCList.filter_map (fun (i, thing) ->
                match Core.Thing.attribute thing attr with
                    | Some cat -> if cat = value
                        then Some [i]
                        else None
                    | _ -> None) in
        if CCList.is_empty rows then
            Some (Table.empty [x])
        else Table.of_list [x] rows