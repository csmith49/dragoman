type t =
    | Relate of Core.Scene.relation * Core.Variable.t * Core.Variable.t
    | Select of Core.Thing.attribute * Core.Cat.t * Core.Variable.t

(* getters *)
let variables = function
    | Relate (_, l, r) -> [l ; r]
    | Select (_, _, x) -> [x]

(* manipulation *)
let remap conjunct mapping = match conjunct with
    | Relate (r, x, y) ->
        Relate (r, Core.Variable.Mapping.remap x mapping, Core.Variable.Mapping.remap y mapping)
    | Select (a, c, x) ->
        Select (a, c, Core.Variable.Mapping.remap x mapping)

(* to and from json *)
let relate_of_json json = let module J = Utility.JSON in
    let relation = J.Parse.get "relation" J.Literal.string json in
    let left = J.Parse.get "left" Core.Variable.of_json json in
    let right = J.Parse.get "right" Core.Variable.of_json json in
    match relation, left, right with
        | Some rel, Some l, Some r -> Some (Relate (rel, l, r))
        | _ -> None

let select_of_json json = let module J = Utility.JSON in
    let attribute = J.Parse.get "attribute" J.Literal.string json in
    let value = J.Parse.get "value" Core.Cat.of_json json in
    let variable = J.Parse.get "variable" Core.Variable.of_json json in
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
            ("left", Core.Variable.to_json x);
            ("right", Core.Variable.to_json y)
        ]
    | Select (attr, value, x) ->
        `Assoc [
            ("kind", `String "select");
            ("attribute", `String attr);
            ("value", Core.Cat.to_json value);
            ("variable", Core.Variable.to_json x)
        ]

let to_string = function
    | Relate (rel, x, y) ->
        rel ^ "(" ^ (Core.Variable.to_string x) ^ ", " ^ (Core.Variable.to_string y) ^ ")"
    | Select (attr, value, x) ->
        (Core.Variable.to_string x) ^ "." ^ attr ^ " = " ^ (Core.Cat.to_string value)


(* equality and the like *)
let equal left right = match left, right with
    | Relate (rel_l, x_l, y_l), Relate (rel_r, x_r, y_r) ->
        (rel_l == rel_r) && (Core.Variable.equal x_l x_r) && (Core.Variable.equal y_l y_r)
    | Select (a_l, val_l, x_l), Select (a_r, val_r, x_r) ->
        (a_l == a_r) && (Core.Cat.equal val_l val_r) && (Core.Variable.equal x_l x_r)
    | _ -> false

let equal_wrt_mapping mapping left right = match left, right with
    | Relate (rel_l, x_l, y_l), Relate (rel_r, x_r, y_r) when rel_l == rel_r ->
        Some (mapping
            |> Core.Variable.Mapping.make_equal_in x_l x_r
            |> Core.Variable.Mapping.make_equal_in y_l y_r)
    | Select (a_l, val_l, x_l), Select (a_r, val_r, x_r) when a_l == a_r ->
        if not (Core.Cat.equal val_l val_r) then None else
        Some (mapping |> Core.Variable.Mapping.make_equal_in x_l x_r)
    | _ -> None

(* table construction *)
let evaluate conjunct scene = match conjunct with
    (* CASE 1 - a relation where x and y are the same *)
    | Relate (rel, x, y) when Core.Variable.equal x y ->
        begin match Core.Scene.relation scene rel with
            | Some relation -> relation
                |> Core.Relation.to_list
                |> CCList.filter_map
                    (fun (i, j) -> if i == j then Some [i] else None)
                |> Core.Table.of_list [x]
            | _ -> Some (Core.Table.empty [x]) end
    (* CASE 2 - a relation where x and y are distinct variables *)
    | Relate (rel, x, y) ->
        begin match Core.Scene.relation scene rel with
            | Some relation -> relation
                |> Core.Relation.to_list
                |> CCList.map (fun (i, j) -> [i ; j])
                |> Core.Table.of_list [x ; y]
            | _ -> Some (Core.Table.empty [x]) end
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
            Some (Core.Table.empty [x])
        else Core.Table.of_list [x] rows

let to_sql = function
    | Relate (rel, x, y) ->
        let q = Printf.sprintf "SELECT source as '%s', destination as '%s' FROM %s" 
            (Core.Variable.to_string x)
            (Core.Variable.to_string y)
            rel
        in SQL.Query.of_string q
    | Select (attr, value, x) ->
        let q = Printf.sprintf "SELECT object as '%s' FROM %s WHERE value = %s"
            (Core.Variable.to_string x)
            attr
            (Core.Cat.to_string value)
        in SQL.Query.of_string q