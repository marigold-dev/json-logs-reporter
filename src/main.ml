let src = Logs.Src.create "main"
module Log = (val Logs.src_log src : Logs.LOG)

let loc_tag: string Logs.Tag.def =
  Logs.Tag.def "loc" ~doc:"Source location" Format.pp_print_string

let add_tag ?(tags = Logs.Tag.empty) tag_def value =
  Logs.Tag.(tags |> add tag_def value)

let here_to_string here =
  Printf.sprintf "%s:%i" here.Lexing.pos_fname here.pos_lnum

let add_location ?tags here =
  add_tag ?tags loc_tag @@ here_to_string here

let run () =
  Log.info (fun m -> m "test" ~tags:(add_tag loc_tag (here_to_string [%here])));
  Log.warn (fun m -> m "test" ~tags:(add_tag loc_tag (here_to_string [%here])));
  Log.err (fun m -> m "err test" ~tags:(add_tag loc_tag (here_to_string [%here])));
  Log.debug (fun m -> m "test" ~tags:(add_tag loc_tag (here_to_string [%here])));
  Log.app (fun m -> m "test" ~tags:(add_location [%here]))

let setup_logs () =
  (* Logs.set_reporter (Ezlogs_cli.Json_output.reporter Fmt.stdout); *)
  Logs.set_reporter @@ Json_logs_reporter.reporter Fmt.stdout;
  Logs.set_level (Some Debug)

let () =
  setup_logs ();
  run ();