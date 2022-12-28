## KSP_ENG: KSP Career Mode Script.

The script aims to accompany career mode games and execute most common mission and milestone, automatically.

Highlights including completely autonomous tourist and atmospheric reports missions, and various individual commands that can be strung together to go essentially anywhere without manual input.

This is created so the game can run itself so the human player can watch other things as the script executes routine missions. For instance writing more scripts that does more awesome stuff or watching Kessi in Kerbin Cup.

## Demo

[KSP Career Mode Script Demos](https://www.youtube.com/playlist?list=PLGks7zbRYSDxT3P7UUZqm2-lpg0A6tWXP)

## General Usage

The scripts are organized into 2 command pattern entry points. Most of the heavy lifting is done in `lib/` folder, and the command scripts present a unified UI for commands to be entered. The commands are entered as thus:

```
run flight("$ACTION", [$ARG1, $ARG2, $ARG3]).
run craft("$ACTION", [$ARG1, $ARG2, $ARG3]).
```

`flight` command correspond to a list of actions that make the most sense inside of an atmosphere, e.g. flying an aircraft. `craft` command correspond to a list of actions that make the most sense in space, in launch or landing scenarios.

For example:

```
run craft("lko").
```

Will automatically tell the rocket to execute a series of command that includes launch, orbit, deorbit, landing via parachutes back near the KSC. Whereas

```
run craft("lko", 5, 90000, false).
```

Will tell the rocket to launch into an circular orbit of 90000m, without staging at the end, and stop at step 5 (which prevents deorbit, landing steps from being executed).

Another example for `flight`:

```
run flight("auto", 14000, "barometer").
```

If you have a mission to measure the pressure of various destination of kerbin, and select one of the destination as target, the plane will automatically take off from KSC, fly to that location on a stable height of 14000m, when approaching, will automatically adjust its height to the approximate height of the mission and record the pressure automatically. It will then set the next destination automatically and fly there without any intervention. After all destinations for that mission is completed, it will automatically land itself.

There are other more specific commands that are very useful, for instance:

```
run craft("node").
```

This execute the next node encounter down to the accuracy of 0.1m/s deltaV.

### `craft` Command

This command are for spaceflight operations.

| Command | Arguments | Description |
| --- | --- | --- |
| `node` | `run craft("node"[, $allow_stage(true)])` | Execute the next manuever node, default to allow staging if fuel runs out in the middle |
| `circ` | `run craft("circ"[, $is_ap(true)[, $run(false)]])` | Creates a node to circularize, default to circularize at apoapsis, and can optionally warp forward and execute the node if run command is `true` |
| `parachute` | `run craft("parachute"[, $service_bay(true)[, $parachute(true]])` | Land from upper atmosphere, `$service_bay` opens service bay to help aerodynamics, and `$parachute` would stage parachutes, if no parachutes exist, it attempts a suicide burn to land. |
| `deorbit` | `run craft("deorbit"[, $service_bay(true)[, $parachute(true)]])` | Land from kerbin orbit, it aims for KSC and engage `parachute` command after entering atmosphere |
| `set_apoapsis[periapsis]` | `run craft("set_apoapsis", $altitude[, $run(false)])` | Set apoapsis (or periapsis) by creating a manuever node at periapsis (or apoapsis), can pass in a `$run` parameter to warp and execute the manuever node. |
| `suicide_burn` | `run craft("suicide_burn")` | Suicide burn and land on the surface. Works for any celestial body provided you have enough thrust and dV |
| `hohmann` | `run craft("hohmann", $altitude, $wait)` | Runs a hohmann transfer to orbit of another altitude, wait should be at least `60` |
| `hohmann_target` | `run craft("hohmann_target"[, $angdiff(0)[, $run(false)]])` | Automatically create a hohmann transfer to intersect with the target object. This assume the target orbit is circular. `$angdiff` parameter is by default 0, which means it will intersect the orbit with phase of 0 degrees, useful for going to a space station, set it to `60` or `90` to build a constellation of satellite that are spaced 60/90 degrees apart. `$run` will execute the hohmann insertion manuever |
| `match_inc` | `run craft("match_inc"[, $run(false)])` | Matches inclination of the target orbit. |
| `parts_act` | `run craft("parts_act", $part_name, $action_name)` | Perform specified action on parts, parts name can be abbreviations and will be used against all parts that contain the string, for instance `run craft("parts_act", "voltaic", "extend").` will extend all photovoltaic panels on the spacecraft |

