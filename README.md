# Paradeiser

[![Gem Version](https://badge.fury.io/rb/paradeiser.png)](http://badge.fury.io/rb/paradeiser)
[![Build Status](https://secure.travis-ci.org/nerab/paradeiser.png?branch=master)](http://travis-ci.org/nerab/paradeiser)

  _This project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. This file describes the functionality that is actually implemented, whereas the [VISION](VISION.md) reflects the vision where the tool should go._

Paradeiser is a command-line tool for the [Pomodoro Technique](http://www.pomodorotechnique.com/). It keeps track of the current pomodoro and assists the user in managing active and past pomodori:

* Records finished and cancelled pomodori as well as internal and external interruptions and other events
* Keeps track of the timer for the active pomodoro and the break
* Provides out-of-the-box reports that show details about finished and cancelled pomodori
* Shows information about breaks and interruptions

Paradeiser itself is not concerned with the actual management of tasks. There are plenty of tools for that; e.g. [TaskWarrior](http://taskwarrior.org/).

## Concepts

### Rule #1

  There must never be more than one pomodoro [xor](http://en.wikipedia.org/wiki/Xor) break at any given time.

This is scoped to a single user account (not just the `$PAR_DIR` directory, but also the `at` queue).

## Installation

      $ gem install paradeiser

## Usage

### Start a new pomodoro

      $ par pomodoro start

If a break is still active, it will be stopped before the new pomodoro is started. Because of Rule #1, calling start while a pomodoro is active will print an error message.

### Finish the pomodoro

      $ par pomodoro finish

If a pomodoro is active, it will be marked as successful after stopping it, regardless of whether the 25 minutes are over or not.

If there is no active pomodoro, an error message will be printed.

### Record an interruption of the current pomodoro

      $ par interrupt
      $ par interrupt --external

If no pomodoro is active, the command will throw an error.

### Start a break

      $ par break [start]

If there is an active pomodoro, an error message will be printed. The `start` command is optional and may be omitted (it's only there for symmetry with `par break finish`, see the section about `at`).

By default the break will be five minutes long.

While there is a command to stop a break (see the section about `at`), it isn't really necessary to call it from a user's perspective. Either a new pomodoro is started, which will implicitely stop the break, or the break ends naturally because it is over. We do not track break time.

### Cancel the pomodoro

      $ par pomodoro cancel

It will be marked as unsuccessful (remember, a pomodoro is indivisible). If no pomodoro is active, the command will throw an error. If a break is active, the command will do nothing except printing a warning.

### Initialize Paradeiser

* Initialize the default directory that is used to store the Paradeiser configuration and data:

          $ par init

  Creates the `$PAR_DIR` directory and the sample hooks in `$PAR_DIR/hooks`. The data store will not be created on `par init`, but when the first write operation happens (e.g. `par pomodoro start`, but not `par report`).

* Initialize an abritrary directory

          $ par init /tmp

  This command initializes `/tmp` as `$PAR_DIR`.

## Timer with `at`

A central aspect of the Pomodoro Technique is the timer function:

  * The remaining time of the active pomodoro or break must be displayed to the user.
  * When the pomodoro or break is over, the user also needs to get a notification.

The `at` command is used for this. We just tell it to call

      par pomodoro finish

when the pomodoro is over. A similar command exists as

      par break finish

which is called by `at` when the break is over.

When a pomodoro is started, Paradeiser enqueues itself to `at` like this:

      echo par pomodoro finish | at now + 25 minutes

When `at` calls Paradeiser with this command, the pomodoro / break will be over and Paradeiser can do all the internal processing related to stopping the pomodoro / break (incl. calling the appropriate hooks, see below).

Paradeiser uses a dedicated at queue named 'p' to organize its jobs and to prevent accidentially overwriting other scheduled tasks.

## Status

Paradeiser can print the current status to STDOUT with the `par status` command. The current state is provided as process exit status (which is also useful when the output is suppressed).

* Given an active pomodoro:

          $ par status
          Pomodoro #2 is active (started 11:03, 14 minutes remaining).

          $ par status > /dev/null
          $ echo $?
          0

* Given no active pomodoro and the last one (not earlier as today) was finished:

          $ par status
          No active pomodoro. Last one was finished at 16:58.

          $ par status > /dev/null
          $ echo $?
          1

* Given no active pomodoro and the last one (not earlier as today) was cancelled:

          $ par status
          No pomodoro active. Last pomodoro was cancelled at 17:07.

          $ par status > /dev/null
          $ echo $?
          2

* Given a break (implies no active pomodoro):

          $ par status
          Taking a 5 minute break until 2013-07-16 17.07 (4 minutes remaining).

          $ par status > /dev/null
          $ echo $?
          3

## Reports

      $ par report
      Pomodoro Report

      4 pomodori finished
      2 pomodori canceled
      4 internal interrupts
      1 external interrupt
      2 breaks (7 minutes in total)

## Output Policy
Paradeiser follows the [Rule of Silence](http://www.faqs.org/docs/artu/ch01s06.html#id2878450). If all goes well, a command will not print any output to `STDOUT` unless `--verbose` is given. `status`, `report` and `timesheet` are exempted from this rule, as their primary purpose is to print to STDOUT.

## Hooks
Instead of handling tasks itself, Paradeiser integrates with external tools via hooks. Every event will attempt to find and execute an appropriate script in `$PAR_DIR/hooks/`. Sufficient information will be made available via environment variables.

`before-` hooks will be called before the action is executed internally. If a `before-`hook exits non-zero, paradeiser will abort the action and exit non-zero itself; indicating in a message to STDERR which hook caused the abort. In this case it will not process `after-` hooks.

`after-` hooks will be called after the action was executed internally. The exit status of a `post`-hook will be passed through paradeiser, but it will not affect the execution of the action anymore.

### Available Hooks

* `before-start-pomodoro` is called before the processing of the start action begins.
* `after-start-pomodoro` is called after the processing of the start action ended.
* `before-finish-pomodoro` is called after the timer of the current pomodoro fired (the pomodoro is over), but before the processing of the `finish` action begins.
* `after-finish-pomodoro` is called after the processing of the `finish` action ended.

* `before-start-break` is called before the processing of the break start action begins.
* `after-start-break` is called after the processing of the break start action ended.
* `before-finish-break` is called after the timer of the current break fired (the break is over), but before the processing of the break finish action begins.
* `after-finish-break` is called after the processing of the break finish action ended.
* `before-interrupt-pomodoro` is called when the `interrupt` command was received, but before the action processing begins.
* `after-interrupt-pomodoro` is called after the processing of the `interrupt` action ended.
* `before-cancel-pomodoro` is called when the `cancel` command was received, but before the processing of the cancel action begins.
* `after-cancel-pomodoro` is called after the processing of the `cancel` action ended.

Examples for the use of hooks are:

* Displaying a desktop notification on `after-finish-pomodoro`
* tmux status bar integration like [pomo](https://github.com/visionmedia/pomo) by writing the status to `~/.pomo_stat` from the `after-` hooks.
* Displaying a desktop notification

`$PAR_TITLE` is one of the environment variables set by Paradeiser that provides the context for hooks. See below for the full list of available environment variables.

## Environment Variables

Variable | Used in | Description
--- | --- | ---
`$PAR_DIR` | Everywhere | Directory where the data store and the hooks are stored. Defaults to `~/.paradeiser/`.
`$PAR_POMODORO_ID` | Hooks | Identifier of the pomodoro
`$PAR_POMODORO_STARTED_AT` | Hooks | Timestamp of when the pomodoro was started
`$PAR_BREAK_ID` | Hooks | Identifier of the break
`$PAR_BREAK_STARTED_AT` | Hooks | Timestamp of when the break was started

## Similar Projects

These and many more exist, why another tool?

* https://github.com/visionmedia/pomo
* https://github.com/stefanoverna/redpomo

They have a lot of what I wanted, but pomo focuses very much on the tasks themselves and less on the pomodori.

## Implementation Notes

### State Machine
Paradeiser uses a [state machine](https://github.com/pluginaweek/state_machine) to model a pomodoro. Internal event handlers do the actual work; among them is the task of calling the external hooks.

![State Transition Diagram for Pomodoro](https://rawgithub.com/nerab/paradeiser/master/doc/Paradeiser::Pomodoro_status.svg)
![State Transition Diagram for Break](https://rawgithub.com/nerab/paradeiser/master/doc/Paradeiser::Break_status.svg)

The graph was created using the rake task that comes with `state_machine`:

    rake state_machine:draw CLASS=Paradeiser::Pomodoro TARGET=doc FORMAT=svg HUMAN_NAMES=true ORIENTATION=landscape
    rake state_machine:draw CLASS=Paradeiser::Break    TARGET=doc FORMAT=svg HUMAN_NAMES=true ORIENTATION=landscape

## API
The actual storage backend is *not a public API* and may change at any given time. External tools should use the Ruby API instead, or rely on the JSON export / import.

## Sync
In todays world of distributed devices, synching data is a problem almost every app needs to solve. Paradeiser is no exception - it is very easy to come up with use cases that involve many computers. Maybe the user has different devices (mobile and desktop), maybe the user works in different environments, and wants to record all pomodori into a single system.

There are many potential solutions to this problem:

  1. A centralized server could host a data store (relational database, NoSQL store, etc.)
  1. A shared directory could host a single file and access could be coordinated using lock files
  1. Commercial solutions like the [Dropbox Sync API](https://www.dropbox.com/developers/sync)
  1. Custom solutions like [toystore](https://github.com/jnunemaker/toystore) with a [git adapter](https://github.com/bkeepers/adapter-git)

All of these are too much overhead right now, so the decision was made to keep Paradeiser simple and not implement any sync features. This may me revisited in a later version of the app.

## Issues

1. `at` is disabled on MacOS by default. You will need to [turn it on](https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man8/atrun.8.html) in order to make Paradeiser work correctly.

## What about the app's name?
In Austrian German, "Paradeiser" means tomato, of which the Italian translation is pomodoro.
