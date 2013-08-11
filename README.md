# Paradeiser

[![Gem Version](https://badge.fury.io/rb/paradeiser.png)](http://badge.fury.io/rb/paradeiser)
[![Build Status](https://secure.travis-ci.org/nerab/paradeiser.png?branch=master)](http://travis-ci.org/nerab/paradeiser)

  _This project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. This file describes the functionality that is actually implemented, whereas the [VISION](VISION.md) describes the vision where the tool should go._

Paradeiser is a command-line tool for the [Pomodoro Technique](http://www.pomodorotechnique.com/). It keeps track of the current pomodoro and assists the user in managing active and past pomodori:

* Records finished pomodori
* Keeps track of the timer for the active pomodoro and the break
* Provides out-of-the-box reports

Paradeiser itself is not concerned with the actual management of tasks. There are plenty of tools for that; e.g. [TaskWarrior](http://taskwarrior.org/).

## Concepts

### Rule #1

  There must never be more than one pomodoro [xor](http://en.wikipedia.org/wiki/Xor) break at any given time.

This is scoped to a single user account (not just the `$POM_DIR` directory, but also the `at` queue).

## Installation

      $ gem install paradeiser

## Usage

### Start a new pomodoro

      $ pom start

Because of Rule #1, calling start while a pomodoro is active will print an error message.

### Finish the pomodoro

      $ pom finish

If a pomodoro is active, it will be marked as successful after stopping it, regardless of whether the 25 minutes are over or not.

If there is no active pomodoro, an error message will be printed.

### Initialize Paradeiser

* Initialize the default directory that is used to store the Paradeiser configuration and data:

          $ pom init

  Creates the `$POM_DIR` directory and the sample hooks in `$POM_DIR/hooks`. The data store will not be created on `pom init`, but when the first write operation happens (e.g. `pom start`, but not `pom report`).

* Initialize an abritrary directory

          $ pom init /tmp

  This command initializes `/tmp` as `$POM_DIR`.

## Timer with `at`

A central aspect of the Pomodoro Technique is the timer function:

  * The remaining time of the active pomodoro or break must be displayed to the user.
  * When the pomodoro or break is over, the user also needs to get a notification.

The `at` command is used for this. We just tell it to call

      pom finish

when the pomodoro is over.

When a pomodoro is started, Paradeiser enqueues itself to `at` like this:

      echo pom finish | at now + 25 minutes

When `at` calls Paradeiser with this command, the pomodoro / break will be over and Paradeiser can do all the internal processing related to stopping the pomodoro / break (incl. calling the appropriate hooks, see below).

Paradeiser uses a dedicated at queue named 'p' to organize its jobs and to prevent accidentially overwriting other scheduled tasks.

## Status

Paradeiser can print the current status to STDOUT with the `pom status` command. The current state is provided as process exit status (which is also useful when the output is suppressed).

* Given an active pomodoro:

          $ pom status
          Pomodoro #2 is active (started 11:03, 14 minutes remaining).

          $ pom status > /dev/null
          $ echo $?
          0

* Given no active pomodoro and the last one (not earlier as today) was finished:

          $ pom status
          No active pomodoro. Last one was finished at 16:58.

          $ pom status > /dev/null
          $ echo $?
          1

## Reports

      $ pom report
      <list of pomodori>

## Hooks
Instead of handling tasks itself, Paradeiser integrates with external tools via hooks. Every event will attempt to find and execute an appropriate script in `$POM_DIR/hooks/`. Sufficient information will be made available via environment variables.

`before-` hooks will be called before the action is executed internally. If a `before-`hook exits non-zero, paradeiser will abort the action and exit non-zero itself; indicating in a message to STDERR which hook caused the abort.

`after-` hooks will be called after the action was executed internally. The exit status of a `post`-hook will be passed through paradeiser, but it will not affect the execution of the action anymore.

### Available Hooks

* `before-start` is called after the `start` command was received, but before internal processing for the `start` action begins
* `after-start` is called after all interal processing for the `start` action ended
* `before-finish` is called after the timer of the current pomodoro fired (the pomodoro is over), but before internal processing for the `finish` action begins
* `after-finish` is called after all interal processing for the `finish` action ended

Examples for the use of hooks are:

* Displaying a desktop notification on `after-finish`
* tmux status bar integration like [pomo](https://github.com/visionmedia/pomo) by writing the status to `~/.pomo_stat` from the `after-` hooks.
* Displaying a desktop notification

`$POM_TITLE` is one of the environment variables set by Paradeiser that provides the context for hooks. See below for the full list of available environment variables.

## Environment Variables

Variable | Used in | Description
--- | --- | ---
`$POM_DIR` | Everywhere | Directory where the data store and the hooks are stored. Defaults to `~/.paradeiser/`.
`$POM_ID` | Hooks | Identifier of the pomodoro
`$POM_STARTED_AT` | Hooks | Timestamp of when the pomodoro was started

## Similar Projects

These and many more exist, why another tool?

* https://github.com/visionmedia/pomo
* https://github.com/stefanoverna/redpomo

They have a lot of what I wanted, but pomo focuses very much on the tasks themselves and less on the pomodori.

## Implementation Notes

### State Machine
Paradeiser uses a [state machine](https://github.com/pluginaweek/state_machine) to model a pomodoro. Internal event handlers do the actual work; among them is the task of calling the external hooks.

![State Transition Diagram](https://rawgithub.com/nerab/paradeiser/master/doc/Paradeiser::Scheduled_status.svg)

The graph was created using the rake task that comes with `state_machine`:

    rake state_machine:draw CLASS=Paradeiser::Pomodoro TARGET=doc FORMAT=svg HUMAN_NAMES=true ORIENTATION=landscape

## API
The actual storage backend is *not a public API* and may change at any given time.

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
