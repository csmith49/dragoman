open Core

type t = [
    | `Relate of Store.relation_key * Variable.t * Variable.t
    | `Select of Store.relation_key * Variable.t * Value.t
]

let to_query = function
    | `Relate (rk, l, r) when Variable.equal l r ->
        let mapping = [(Query.X.left, l) ; (Query.X.right, r)] in
        `Rename (
            mapping,
            `Select (
                `Equal (Query.X.left, Query.X.right),
                `Relation rk))
    | `Relate (rk, l, r) ->
        let mapping = [(Query.X.left, l) ; (Query.X.right, r)] in
        `Rename (mapping, `Relation rk)
    | `Select (rk, x, v) ->
        let mapping = [(Query.X.left, x)] in
        `Rename (
            mapping,
            `Select (
                `EqualConst (Query.X.left, v),
                `Relation rk))

let variables = function
    | `Relate (_, l, r) -> [l ; r]
    | `Select (_, x, _) -> [x]

let remap conj mapping = match conj with
    | `Relate (rk, l, r) -> `Relate (rk, Variable.Mapping.remap l mapping, Variable.Mapping.remap r mapping)
    | `Select (rk, x, v) -> `Select (rk, Variable.Mapping.remap x mapping, v)

(* to and from json *)
let relate_of_json json = let module J = Utility.JSON in
    let relation = J.Parse.get "relation" J.Literal.string json in
    let left = J.Parse.get "left" Core.Variable.of_json json in
    let right = J.Parse.get "right" Core.Variable.of_json json in
    match relation, left, right with
        | Some rel, Some l, Some r -> Some (`Relate (rel, l, r))
        | _ -> None

let select_of_json json = let module J = Utility.JSON in
    let attribute = J.Parse.get "attribute" J.Literal.string json in
    let value = J.Parse.get "value" Core.Value.of_json json in
    let variable = J.Parse.get "variable" Core.Variable.of_json json in
    match attribute, value, variable with
        | Some attr, Some v, Some x -> Some (`Select (attr, x, v))
        | _ -> None

let of_json json = let module J = Utility.JSON in
    match J.Parse.get "kind" J.Literal.string json with
        | Some s when s = "relate" -> relate_of_json json
        | Some s when s = "select" -> select_of_json json
        | _ -> None

let to_json = function
    | `Relate (rel, x, y) ->
        `Assoc [
            ("kind", `String "relate");
            ("relation", `String rel);
            ("left", Core.Variable.to_json x);
            ("right", Core.Variable.to_json y)
        ]
    | `Select (attr, x, v) ->
        `Assoc [
            ("kind", `String "select");
            ("attribute", `String attr);
            ("value", Core.Value.to_json v);
            ("variable", Core.Variable.to_json x)
        ]

let to_string = function
    | `Relate (rel, x, y) ->
        rel ^ "(" ^ (Core.Variable.to_string x) ^ ", " ^ (Core.Variable.to_string y) ^ ")"
    | `Select (attr, x, v) ->
        (Core.Variable.to_string x) ^ "." ^ attr ^ " = " ^ (Core.Value.to_string v)


(* equality and the like *)
let equal left right = match left, right with
    | `Relate (rel_l, x_l, y_l), `Relate (rel_r, x_r, y_r) ->
        (rel_l == rel_r) && (Core.Variable.equal x_l x_r) && (Core.Variable.equal y_l y_r)
    | `Select (a_l, x_l, val_l), `Select (a_r, x_r, val_r) ->
        (a_l == a_r) && (Core.Value.equal val_l val_r) && (Core.Variable.equal x_l x_r)
    | _ -> false