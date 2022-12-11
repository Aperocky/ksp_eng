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
