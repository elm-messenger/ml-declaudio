open Js_of_ocaml

(* Core types from Audio.elm *)

(** Buffer identifier wrapper *)
type buffer_id = BufferId of int32

(** Audio source data *)
type source = File of { buffer_id : buffer_id }

(** Loop configuration *)
type loop_config = { loop_start : float; loop_end : float }

(** Audio playback configuration *)
type play_audio_config = {
  loop : loop_config option;
  playback_rate : float;
  start_at : float;  (* Duration in seconds *)
}

(** Audio effects *)
type effect_type =
  | ScaleVolume of { scale_by : float }
  | ScaleVolumeAt of { volume_at : (float * float) list }  (* (time, volume) list *)
  | Offset of float  (* Duration offset in seconds *)

(** Main audio type *)
type audio =
  | Group of audio list
  | BasicAudio of {
      source : source;
      start_time : int32;  (* Unix timestamp in milliseconds *)
      settings : play_audio_config;
    }
  | Effect of {
      effect_type : effect_type;
      audio : audio;
    }

(** Volume timeline type (non-empty list of (time, volume) points) *)
type volume_timeline = (float * float) list

(** Volume timelines (list of volume timelines) *)
type volume_timelines = volume_timeline list

(** Audio loading errors *)
type load_error =
  | FailedToDecode
  | NetworkError
  | UnknownError

(* Helper functions *)

(** Extract raw buffer ID from buffer_id wrapper *)
let raw_buffer_id (BufferId id) = id

(** Default audio playback configuration *)
let audio_default_config : play_audio_config = {
  loop = None;
  playback_rate = 1.0;
  start_at = 0.0;
}

(** Create audio from source with default configuration *)
let audio (source : source) (start_time : int32) : audio =
  BasicAudio { source; start_time; settings = audio_default_config }

(** Create audio from source with custom configuration *)
let audio_with_config (settings : play_audio_config) (source : source) (start_time : int32) : audio =
  BasicAudio { source; start_time; settings }

(** Scale volume of audio *)
let scale_volume (scale_by : float) (audio : audio) : audio =
  let scale_by = max 0.0 scale_by in
  Effect { effect_type = ScaleVolume { scale_by }; audio }

(** Scale volume at specific time points *)
let scale_volume_at (volume_at : (float * float) list) (audio : audio) : audio =
  let volume_at = List.map (fun (t, v) -> (t, max 0.0 v)) volume_at in
  Effect { effect_type = ScaleVolumeAt { volume_at }; audio }

(** Offset audio by duration *)
let offset_by (offset : float) (audio : audio) : audio =
  Effect { effect_type = Offset offset; audio }

(** Combine multiple audio items into a group *)
let group (audios : audio list) : audio =
  Group audios

(** Create silence (empty audio group) *)
let silence : audio =
  group []

let gen_volume_timelines : volume_timelines -> Js.Unsafe.any =
 fun vts ->
  let timeline_to_js (timeline : (float * float) list) =
    let points =
      Array.map
        (fun (t, v) ->
          Js.Unsafe.obj
            [|
              ("time", Js.Unsafe.inject (Js.float t));
              ("volume", Js.Unsafe.inject (Js.float v));
            |])
        (Array.of_list timeline)
    in
    Js.array points
  in
  let timelines_js = List.map timeline_to_js vts in
  Js.Unsafe.inject (Js.array (Array.of_list timelines_js))

let stop_sound (node_id : int32) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "stopSound"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
    |]

let set_volume (node_id : int32) (volume : float) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setVolume"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("volume", Js.Unsafe.inject (Js.float volume));
    |]

let set_volume_at (node_id : int32) (volumeat : volume_timelines) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setVolumeAt"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("volumeAt", gen_volume_timelines volumeat);
    |]

let get_loop_start (cfg : loop_config option) : Js.Unsafe.any =
  match cfg with
  | Some c -> Js.Unsafe.inject @@ Js.float c.loop_start
  | None -> Js.Unsafe.inject Js.null

let get_loop_end (cfg : loop_config option) : Js.Unsafe.any =
  match cfg with
  | Some c -> Js.Unsafe.inject @@ Js.float c.loop_end
  | None -> Js.Unsafe.inject Js.null

let set_loop_config (node_id : int32) (loop : loop_config option) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setLoopConfig"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("loopStart", get_loop_start loop);
      ("loopEnd", get_loop_end loop);
    |]

let set_playback_rate (node_id : int32) (playback_rate : float) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setPlaybackRate"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("playbackRate", Js.Unsafe.inject (Js.float playback_rate));
    |]

let start_sound (node_id : int32) (buffer_id : int32) (volume : float)
    (volume_timelines : volume_timelines) (start_time : int32)
    (start_at : float) (loop : loop_config option) (playback_rate : float) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "startSound"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("bufferId", Js.Unsafe.inject (Js.int32 buffer_id));
      ("startTime", Js.Unsafe.inject (Js.int32 start_time));
      ("volume", Js.Unsafe.inject (Js.float volume));
      ("volumeTimelines", gen_volume_timelines volume_timelines);
      ("startAt", Js.Unsafe.inject (Js.float start_at));
      ("loopStart", get_loop_start loop);
      ("loopEnd", get_loop_end loop);
      ("playbackRate", Js.Unsafe.inject (Js.float playback_rate));
    |]

let load_audio (audio_url : string) (req_id : int32) =
  Js.Unsafe.obj
    [|
      ("audioUrl", Js.Unsafe.inject (Js.string audio_url));
      ("requestId", Js.Unsafe.inject (Js.int32 req_id));
    |]

let execCmd x =
  let mlda = Js.Unsafe.global##.MlDeclAudio in
  mlda##execCmd x
