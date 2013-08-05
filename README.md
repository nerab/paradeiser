# Paradeiser

[![Gem Version](https://badge.fury.io/rb/paradeiser.png)](http://badge.fury.io/rb/paradeiser)
[![Build Status](https://secure.travis-ci.org/nerab/paradeiser.png?branch=master)](http://travis-ci.org/nerab/paradeiser)

  _Please note that this project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. As such, Paradeiser actually provides much less functionality than it is described here. Once a major milestone is reached, this README will be updated to reflect the actual status._

Paradeiser is a command-line tool for the [Pomodoro Technique](http://www.pomodorotechnique.com/). It keeps track of the current pomodoro and assists the user in managing active and past pomodori:

* Records finished and cancelled pomodori as well as internal and external interruptions and other events
* Keeps track of the timer for the active pomodoro and the break
* Provides out-of-the-box reports that show details about finished and cancelled pomodori
* Shows information about breaks and interruptions

Paradeiser itself is not concerned with the actual management of tasks. There are plenty of tools for that; e.g. [TaskWarrior](http://taskwarrior.org/).

## Concepts

### Rule #1

  There must never be more than one pomodoro [xor](http://en.wikipedia.org/wiki/Xor) break at any given time.

This is scoped to a single user account (technically, for one `$POM_DIR` directory, which by default is `~/.paradeiser/`).

## Installation

      $ gem install paradeiser

## Usage

### Start a new pomodoro

      $ pom start

If a break is still active, it will be stopped before the new pomodoro is started. Because of Rule #1, calling start while a pomodoro is active will print an error message.

### Finish the pomodoro

      $ pom finish

If a pomodoro is active, it will be marked as successful after stopping it, regardless of whether the 25 minutes are over or not. If a break is active, it will be stopped. If neither a pomodoro nor or break are active, an error message will be printed.

### Record an interruption of the current pomodoro

      $ pom interrupt --external Phone call from boss
      $ pom interrupt --internal "Couldn't stay away from Twitter"

Remaining arguments, if present, will be added to the interrupt as annotation. If no pomodoro is active, the command will throw an error.

### Start a break

      $ pom break [--short | --long]

If a pomodoro is active, it will be stopped. By default the break will be five minutes long. After four pomodori within a day, the break will be 30 minutes long. This can be overridden with `--short` or `--long`, with an optional argument value that determines the lenght of the break in minutes (e.g. `pom break --short=10`).

There is no public command to stop a break. Either a new pomodoro is started, which will implicitely stop the break, or the break ends naturally because it is over.

### Annotate a pomodoro

      $ pom annotate This was intense, but I am happy about the work I finished.

The annotation will be added to the active or, if none is active, to the most recently finished or cancelled pomodoro. Breaks cannot have annotations. If no text is given, the annotation text is read from STDIN.

### Cancel the pomodoro

      $ pom cancel Just couldn't concentrate anymore.

It will be marked as unsuccessful (remember, a pomodoro is indivisible). If no pomodoro is active, the command will throw an error. If a break is active, the command will do nothing except printing a warning. Remaining arguments, if present, will be added to the pomodoro as annotation.

### Init Paradeiser

      $ pom init

Creates the `$POM_DIR` directory (defaults to `~/.paradeiser`) and the sample hooks in `$POM_DIR/hooks`. The data store will not be created on `pom init`, but when the first write operation happens (e.g. `pom start`, but not `pom report`).

If `$POM_DIR` already exists, the command will fail with an error message.

### Location
Recording the location of a pomodoro allows Paradeiser to compare the average count of successful and cancelled pomodori and the number of interruptions by location, so that a report can tell in which environment we get the most work done.

  * Show the current location

        $ pom location
        Home Office

        $ pom location --verbose
        Home Office (macbook@01:23:45:67:89:0A)

  * List all locations

        $ pom locations
        Home Office
        Starbucks

        $ pom locations --verbose
        Home Office (macbook@01:23:45:67:89:0A)
        Starbucks (macbook@45:01:89:0A:67:23)

  * Show the label of a location identifier

        $ pom location macbook@01:23:45:67:89:0A
         Home Office

  * Show the identifier of a location

        $ pom location "Home Office"
        macbook@01:23:45:67:89:0A

  * Label a location

        $ pom location macbook@01:23:45:67:89:0A "Your Label"

Paradeiser will automatically figure out the current location from the hostname and the MAC address of the default gateway (see below for details). This can be overridden by setting `$POM_LOCATION` or with a command line option:

    $ pom location --location="On the road"
    On the road

    $ POM_LOCATION="On the road" pom location
    On the road

Both the `--location` option and the environment variable can be passed to almost all commands.

## Timer with `at`

A major aspect of a pomodoro timer is the timer function itself:

  * The remaining time of the active pomodoro or break must be displayed to the user.
  * When the pomodoro or break is over, the user also needs to get a notification.

The `at` command is used for this. We just tell it to call

      pom finish

when the pomodoro is over. A similar command exists for

      pom break finish

that is called by `at` when the break is over.

When a pomodoro is started, Paradeiser enqueues itself to `at` like this:

      echo pom finish | at now + 25 minutes

When `at` calls Paradeiser with this command, the pomodoro / break will be over and Paradeiser can do all the internal processing related to stopping the pomodoro / break (incl. calling the appropriate hooks, see below).

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

* Given no active pomodoro and the last one (not earlier as today) was cancelled:

          $ pom status
          No pomodoro active. Last pomodoro was cancelled at 17:07.

          $ pom status > /dev/null
          $ echo $?
          2

* Given a break (implies no active pomodoro):

          $ pom status
          Taking a 5 minute break until 2013-07-16 17.07 (4 minutes remaining).

          $ pom status > /dev/null
          $ echo $?
          3

* Short status (03:39 remaining in the active pomodoro or break):

          $ pom status --short
          03:39

* Given a break and a custom status format (resembles the format switch analog to `date +%Y-%m-%dT%H:%M:%S`):

          $ pom status --format %C-%M:%S
          B03:39

* Output in JSON format

          $ pom status --format JSON
          {
            "status": {
              "state": "break",
              "length": 600,
              "remaining": 363,
              "start": 1373988295,
              "end": 1373988595
            }
          }

## Reports

      $ pom report
      Daily Pomodoro Report for 2013-07-16

      3 pomodori finished
      1 pomodoro cancelled
      1 internal interruptions
      2 external interruptions
      4 breaks (3 short, 1 long; 45 minutes in total)

      Most efficient location: Home Office
      Least efficient location: Coffeshop

By default, the command groups by `--day`. Alternative options are `--week`, `--month` or `--year`. Without a value, the argument assumes the current day / week / month / year. The first day of the period can be specified as argument, e.g. `pom report --day=2013-07-18`. The period is parsed with [Chronic](http://chronic.rubyforge.org/), which also enables symbolic values like `pom report --month="last month"`.

The report can also be grouped by location:

      $ pom report location
      Pomodoro Location Report

      Home Office: 38 finished, 12 cancelled, 21 interrupts
      Starbucks:   12 finished, 2 cancelled, 45 interrupts
      On the road: 14 finished, 0 cancelled, 12 interrupts

      The following locations do not have a label. Assign it with

        $ pom location macbook@01:23:45:67:89:0A "Your Label"

Detailed report for a single location:

      $ pom report location "Home Office"
      Pomodoro Location Report for Home Office

      58 pomodori finished
      12 pomodoro cancelled
       8 internal interruptions
      13 external interruptions
      18 breaks (13 short, 5 long; 4 hours in total)

      Efficiency: 0.8 (10% over median)

Further grouping is also possible, e.g. by year:

      $ pom report location --year=2012
      Pomodoro Location Report for 2012

      233 pomodori finished
       41 pomodoro cancelled
       33 internal interruptions
      123 external interruptions
       98 breaks (63 short, 35 long; 45 hours in total)

      Most efficient month: September (0.75)
      Least efficient month: July (0.58)

### Efficiency
The efficiency is calculated from the number of successful vs. cancelled pomodori, together with the number interruptions. Breaks are not counted towards efficiency.

Efficiency can be reported by day, week, month, year, or location:

      $ pom report efficiency
      Efficiency Report for 2013-07-16

      TODO

### Analytics

* Influence of interrupts to efficiency
  - 80% of the internal interruptions happen within 5 minutes after the start
  - In the last 3 months, the ratio between (internal / external) interrupts and cancelled pomodori improved by 10% from 0.6 to 0.5.

### Timesheet

      $ pom timesheet
      TODO Ordered list of pomodori and breaks, each with annotations (like a time sheet)

The same options as for regular reports apply. The timesheet report also details the efficiency of each location.

### Exporting a Report

      $ pom report --weekly --format JSON # weekly report in JSON format
      {
        "TODO": "Specify"
      }

## Output Policy
Paradeiser follows the [Rule of Silence](http://www.faqs.org/docs/artu/ch01s06.html#id2878450). If all goes well, a command will not print any output to `STDOUT` unless `--verbose` is given. `status`, `report` and `timesheet` are exempted from this rule, as their primary purpose is to print to STDOUT.

## Hooks
Instead of handling tasks itself, Paradeiser integrates with external tools via hooks. Every event will attempt to find and execute an appropriate script in `~/.paradeiser/hooks/`. Sufficient information will be made available via environment variables.

`pre-` hooks will be called before the action is executed internally. If a `pre-`hook exits non-zero, paradeiser will abort the action and exit non-zero itself; indicating in a message to STDERR which hook caused the abort.

`post-` hooks will be called after the action was executed internally. The exit status of a `post`-hook will be passed through paradeiser, but it will not affect the execution of the action anymore.

### Available Hooks

* `pre-start` is called after the `start` command was received, but before internal processing for the `start` action begins
* `post-start` is called after all interal processing for the `start` action ended
* `pre-finish` is called after the timer of the current pomodoro fired (the pomodoro is over), but before internal processing for the `finish` action begins
* `post-finish` is called after all interal processing for the `finish` action ended
* `pre-interrupt` is called after the `interrupt` command was received, but before internal action processing begins
* `post-interrupt` is called after all interal processing for the `interrupt` action ended
* `pre-cancel` is called after the `cancel` command was received, but before internal action processing begins
* `post-cancel` is called after all interal processing for the `cancel` action ended
* `pre-break` is called after the `break` command was received, but before internal processing for the `break` action begins
* `post-break` is called after the timer of the current break fired (the break is over), but after internal processing for the `break` action ended

Commands are invoked by the user (e.g. `pom start`). Actions are what Paradeiser does internally.

Examples for the use of hooks are:

* Displaying a desktop notification on `pre-finish`
* tmux status bar integration like [pomo](https://github.com/visionmedia/pomo) by writing the status to `~/.pomo_stat` from the `post-` hooks.
* Displaying a desktop notification on Linux:

        # ~/.paradeiser/hooks/post-stop
        notify-send "Break" "$POM_TITLE is over." -u critical

* Displaying a desktop notification on MacOS:

        # ~/.paradeiser/hooks/post-stop
        terminal-notifier-success  -message "$POM_TITLE is over."

`$POM_TITLE` is one of the environment variables set by Paradeiser that provides the context for hooks. See below for the full list of available environment variables.

### Edit a hook

      $ pom edit post-stop

Launches `$VISUAL` (or, if empty, `$EDITOR`) with the given hook.

## Taskwarrior Integration

This is deployed to `~/.paradeiser/hooks/post-finish` by default.

      # exit unless $(task)

      # find all active
      active = $(task active) # doesn't work yet; find the right column with 'task columns' and the info in http://taskwarrior.org/projects/taskwarrior/wiki/Feature_custom_reports

      # TODO tag all active tasks so that we can re-start them

      # stop all active
      task $(task active) stop

## Similar Projects

These and many more exist, why another tool?

* https://github.com/visionmedia/pomo
* https://github.com/stefanoverna/redpomo

They have a lot of what I wanted, but pomo focuses very much on the tasks themselves and less on the pomodori.

## Implementation Notes

### State Machine
Paradeiser uses a [state machine](https://github.com/pluginaweek/state_machine) to model a pomodoro. Internal event handlers do the actual work; among them is the task of calling the external hooks.

![State Transition Diagram](https://rawgithub.com/nerab/paradeiser/master/doc/Paradeiser::Pomodoro_status.svg)

The graph was created using the rake task that comes with `state_machine`:

    rake state_machine:draw CLASS=Paradeiser::Pomodoro TARGET=doc FORMAT=svg HUMAN_NAMES=true ORIENTATION=landscape

### I18N
Paradeiser uses [I18N](https://github.com/svenfuchs/i18n) to translate messages and localize time and date formats.

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

## Location
In order to record the current location at the start of the pomodoro, Paradeiser will record the hostname and the MAC address of the default gateway:

* OSX

        arp 0.0.0.0 | head -1 | awk {'print $4'}

* Linux:

        GATEWAY=$(netstat -rn | grep "^0.0.0.0" | cut -c17-31); ping -c1 $GATEWAY >/dev/null; arp -n $GATEWAY | tail -n1 | cut -c34-50

The location is then used to assign a label to one or more hostname@MAC strings, which will be used in a report.

## Issues

1. `at` is disabled on MacOS by default. You will need to [turn it on](https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man8/atrun.8.html) in order to make Paradeiser work correctly.

## What about the app's name?
In Austrian German, "Paradeiser" means tomato, of which the Italian translation is pomodoro.
