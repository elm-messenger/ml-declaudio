open Js_of_ocaml
open Ml_declaudio

let cmd1 = Declaudio.load_audio "sd" 2l

let timelines1 : Declaudio.volume_timelines =
  [ [ (0., 0.0); (1., 1.0); (2., 0.5) ]; [ (3., 0.0); (4., 0.8); (10., 0.0) ] ]

let cmd2 = Declaudio.start_sound 1l 2l 3. timelines1 2. 2. None 3.

let export_app () =
  Js.export "App"
    (Js.Unsafe.obj
       [| ("cmd1", Js.Unsafe.inject cmd1); ("cmd2", Js.Unsafe.inject cmd2) |])

let _ = export_app ()
