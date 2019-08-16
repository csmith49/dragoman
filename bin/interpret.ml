let input_filename = ref ""
let output_filename = ref ""
let verbose = ref false

(* spec list *)
let spec = [
    ("-i", Arg.Set_string input_filename, " Path to input problem file") ;
    ("-o", Arg.Set_string output_filename, " Path to output file");
    ("-v", Arg.Set verbose, " Enables verbose output");
]

(* parse the command line arguments *)
let anon_fun _ = ()
let usage_msg = "Interprets Horn clauses over CLEVR scenes"
let _ = Arg.parse spec anon_fun usage_msg

(* setting up verbose output *)
let vprint str = if !verbose then print_endline str else ()

(* load the input file *)
let _ = vprint "Loading problem..."
let problem = Yojson.Basic.from_file !input_filename
    |> Problem.of_json
    |> CCOpt.get_exn

let _ = vprint ("Evaluating " ^ (Horn.Clause.to_string problem.clause) ^ "...")
let table = Horn.Clause.evaluate problem.clause problem.scene
    |> CCOpt.get_exn

let _ = vprint "Writing output..."
let _ = if !output_filename = "" 
    then table |> Horn.Table.to_json |> Yojson.Basic.pretty_to_string |> print_endline
    else table |> Horn.Table.to_json |> Yojson.Basic.to_file !output_filename

let _ = vprint "Done."