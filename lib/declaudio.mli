val stop_sound : int32 -> 'a
val set_volume : int32 -> float -> 'a
val set_volume_at : int32 -> float -> 'a
type loop_config = { loop_start : float; loop_end : float; }
val get_loop_start : loop_config option -> Js_of_ocaml.Js.Unsafe.any
val get_loop_end : loop_config option -> Js_of_ocaml.Js.Unsafe.any
val set_loop_config : int32 -> loop_config option -> 'a
val set_playback_rate : int32 -> float -> 'a
type volume_timelines = (float * float) list list
val gen_volume_timelines : volume_timelines -> Js_of_ocaml.Js.Unsafe.any
val start_sound :
  int32 ->
  int32 ->
  float ->
  volume_timelines -> float -> float -> loop_config option -> float -> 'a
val load_audio : string -> int32 -> 'a
