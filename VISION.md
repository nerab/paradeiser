# Paradeiser

[![Gem Version](https://badge.fury.io/rb/paradeiser.png)](http://badge.fury.io/rb/paradeiser)
[![Build Status](https://secure.travis-ci.org/nerab/paradeiser.png?branch=master)](http://travis-ci.org/nerab/paradeiser)

  _This project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. This file contains the vision, whereas the [README](README.md) reflects the functionality that is actually implemented._

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

      # Abbreviated version:
      $ par start

If a break is still active, it will be stopped before the new pomodoro is started. Because of Rule #1, calling start while a pomodoro is active will print an error message.

### Finish the pomodoro

      $ par pomodoro finish

      # With annotation:
      $ par pomodoro finish This one went very well.

      # Abbreviated version:
      $ par finish

      # Abbreviated version with annotation:
      $ par finish This one went very well.

If a pomodoro is active, it will be marked as successful after stopping it, regardless of whether the 25 minutes are over or not. Remaining arguments, if present, will be added to the pomodoro as annotation.

If there is no active pomodoro, an error message will be printed.

### Record an interruption of the current pomodoro

      $ par pomodoro interrupt
      $ par pomodoro interrupt --external

      # Abbreviated version:
      $ par interrupt

      # With annotation:
      $ par pomodoro interrupt Could not help checking my mail
      $ par pomodoro interrupt --external VP of engineering walked into my office

      # Abbreviated version with annotation:
      $ par interrupt Could not help checking my mail

Remaining arguments, if present, will be added to the interrupt as annotation. If no pomodoro is active, the command will throw an error.

### Start a break

      $ par break [start] [--short | --long]

If there is an active pomodoro, an error message will be printed. The `start` command is optional and may be omitted (it's only there for symmetry with `par break finish`, see the section about `at`).

By default the break will be five minutes long. After four pomodori within a day, the break will be 30 minutes long. This can be overridden with `--short` or `--long`, with an optional argument value that determines the lenght of the break in minutes (e.g. `par break --short=10`).

There is a command to stop a break (see also the section about `at`):

      $ par break finish

From a user's perspective it isn't really necessary to call `par break finish`, because either a new pomodoro is started, which will implicitely stop the active break, or the break ends naturally because it is over.

We do not track break time.

### Annotate a pomodoro

      $ par pomodoro annotate This was intense, but I am happy about the work I finished.

      # Abbreviated version:
      $ par annotate This was intense, but I am happy about the work I finished.

The annotation will be added to the active or, if none is active, to the most recently finished or cancelled pomodoro. If no text is given, the annotation text is read from STDIN.

Breaks cannot have annotations.

### Cancel the pomodoro

      $ par pomodoro cancel
      $ par pomodoro cancel Just couldn't concentrate anymore.

      # Abbreviated version:
      $ par cancel

      # Abbreviated version with annotation:
      $ par cancel Just couldn't concentrate anymore.

The pomodoro will be marked as canceled and the timer will be cleared. If no pomodoro is active, the command will throw an error. If a break is active, the command will do nothing except printing a warning. Remaining arguments, if present, will be added to the pomodoro as annotation.

### Log a pomodoro

      $ par pomodoro log

Add a successfully finished pomodoro that was never recorded as being started (maybe the user forgot to call `par pomodoro start`). It will appear in the reports and will count towards efficiency calculations.

The current time will be used for the finish timestamp, and the start time will be calculated backwards from the finish time.

### Initialize Paradeiser

* Initialize the default directory that is used to store the Paradeiser configuration and data:

          $ par init

  Creates the `$PAR_DIR` directory and the sample hooks in `$PAR_DIR/hooks`. The data store will not be created on `par init`, but when the first write operation happens (e.g. `par pomodoro start`, but not `par report`).

* Initialize an abritrary directory

          $ par init /tmp

  This command initializes `/tmp` as `$PAR_DIR`. It also sets the config variable `dir` in `~/.pomrc`:

          $ par config

If the `at` command is not available or not enabled, `par init` will issue a warning. The program will continue because it is still useful for recording, although it will not be able to enqueue itself in order to execute the (time-based) `before-finish-pomodoro` and `before-finish-break` hooks.

### Troubleshooting

`par doctor` performs a number of checks that ensure that Paradeiser can run with best results.

It checks if

* `at` is there and enabled
* ...

`par doctor` also provides a hint on how to correct that situation.

### Location
Recording the location of a pomodoro allows Paradeiser to compare the average count of successful and cancelled pomodori and the number of interruptions by location, so that a report can tell in which environment we get the most work done.

  * Show the current location

        $ par location
        Home Office

        $ par location --verbose
        Home Office (macbook@01:23:45:67:89:0A)

  * List all locations

        $ par locations
        Home Office
        Starbucks

        $ par locations --verbose
        Home Office (macbook@01:23:45:67:89:0A)
        Starbucks (macbook@45:01:89:0A:67:23)

  * Show the label of a location identifier

        $ par location macbook@01:23:45:67:89:0A
         Home Office

  * Show the identifier of a location

        $ par location "Home Office"
        macbook@01:23:45:67:89:0A

  * Label a location

        $ par location macbook@01:23:45:67:89:0A "Your Label"

Paradeiser will automatically figure out the current location from the hostname and the MAC address of the default gateway (see below for details). This can be overridden by setting `$PAR_LOCATION` or with a command line option:

    $ par location --location="On the road"
    On the road

    $ PAR_LOCATION="On the road" par location
    On the road

Both the `--location` option and the environment variable can be passed to almost all commands.

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

Paradeiser can print the current status to STDOUT with the `par status` command. The current state is also provided as process exit status (which is useful when the output is suppressed).

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

* Short status (03:39 remaining in the active pomodoro or break):

          $ par status --short
          03:39

* Given a break and a custom status format (resembles the format switch analog to `date +%Y-%m-%dT%H:%M:%S`):

          $ par status --format %C-%M:%S
          B03:39

* Output in JSON format

          $ par status --format JSON
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

Without arguments, a report is shown for the most recent pomodoro or break.

* Given the most recent item was a pomodoro, finished today:

      $ par report
      # Report for pomodoro #12

      Started 17:07, finished 17:32

      ## Interrupts
      0 internal
      0 external

      ## Annotations
      * This one went very well.

A report can produced for a specific pomodoro or break (here, it was started earlier today and then cancelled after a few interruptions):

      $ par report 11
      # Report for pomodoro #11

      Started 11:34, canceled 11:40

      ## Interrupts
      2 internal:

      * Could not help checking my mail
      * Surfin' the web

      1 external:
      * VP of engineering walked into my office

      # Annotations
      * Right before lunch doesn't seem like a good time for a pomodoro.

Reports can also be grouped by `--day`, `--week`, `--month`, `--year`, or `--all`:

      $ par report --day
      # Daily Report for 2013-07-16

      ## Pomodori
      - 3 finished
      - 1 cancelled

      ## Interrupts
      - 1 internal
      - 2 external

      ## Breaks
      - 3 short
      - 1 long

      Total: 4 breaks, 45 minutes

      ## Locations
      Most efficient: Home Office
      Least efficient: Coffeshop

Without a value, the argument assumes the current day / week / month / year. The first day of the period can be specified as argument, e.g. `par report --day=2013-07-18`. The period is parsed with [Chronic](http://chronic.rubyforge.org/), which also enables symbolic values like `par report --month="last month"`.

Note that the annotations section is not shown if there are no annotations.

The report can also be grouped by location:

      $ par report --location
      # Location Report

      ## Home Office
      38 finished
      12 cancelled
      21 interrupts

      ## Starbucks
      12 finished
      2 cancelled
      45 interrupts

      ## On the road
      14 finished
      0 cancelled
      12 interrupts

      The following locations do not have a label. Assign it with

        $ par --location macbook@01:23:45:67:89:0A "Your Label"

Detailed report for a single location:

      $ par report --location="Home Office"
      # Location Report for Home Office

      58 pomodori finished
      12 pomodoro cancelled
       8 internal interruptions
      13 external interruptions
      18 breaks (13 short, 5 long; 4 hours in total)

      Efficiency: 0.8 (10% over median)

Further grouping is also possible, e.g. by year:

      $ par report --location --year=2012
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

      $ par report efficiency
      Efficiency Report for 2013-07-16

      TODO

### Analytics

* Influence of interrupts to efficiency
  - 80% of the internal interruptions happen within 5 minutes after the start
  - In the last 3 months, the ratio between (internal / external) interrupts and cancelled pomodori improved by 10% from 0.6 to 0.5.

### Timesheet

      $ par timesheet
      TODO Ordered list of pomodori and breaks, each with annotations (like a time sheet)

The same options as for regular reports apply. The timesheet report also details the efficiency of each location.

### Report Formatting
By default The output of reports is formatted as [markdown](http://TODO), so that it can easily be read at the command line, but also piped into a markdown processor, e.g. for HTML generation with [redcloth](http://TODO):

      $ par report | redcloth | bcat

Here, the HTML produced by redcloth is piped into `bcat`, which opens a browser with the produced HTML.

### Exporting a Report

      $ par report --weekly --format JSON # weekly report in JSON format
      {
        "TODO": "Specify"
      }

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

### Edit a hook

      $ par edit after-stop

Launches `$VISUAL` (or, if empty, `$EDITOR`) with the given hook.

## Environment Variables

Variable | Used in | Description
--- | --- | ---
`$PAR_DIR` | Everywhere | Directory where the data store and the hooks are stored. Defaults to `~/.paradeiser/`.
`$PAR_POMODORO_ID` | Hooks | Identifier of the pomodoro
`$PAR_POMODORO_STARTED_AT` | Hooks | Timestamp of when the pomodoro was started
`$PAR_BREAK_ID` | Hooks | Identifier of the break
`$PAR_BREAK_STARTED_AT` | Hooks | Timestamp of when the break was started
`$PAR_LOCATION` | Location Commands | Location of the pomodoro

## Configuration File

The configuration is stored in a config file. It is user-editable file, but editing the configuration is also exposed with `par config`.

      $ par config dir
      /home/nerab/.paradeiser

      # Note how setting $PAR_DIR affects par config
      $ PAR_DIR=/tmp par config dir
      /tmp

      $ par config dir /var/tmp
      $ par config dir
      /var/tmp

`par config` shows the _active_ config when called, i.e. it takes `$PAR_DIR` into account.

  Available config variables:

  Variable | Description
  --- | ---
  `PAR_DIR` | Directory where the data store and the hooks are stored. Defaults to `~/.paradeiser/`. Overridden by `$PAR_DIR`.
  `AT_QUEUE` | Name of the `at` queue to use. Defaults to `p`.

## Taskwarrior Integration

This is deployed to `~/.paradeiser/hooks/after-finish` by default.

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
Paradeiser uses a [state machine](https://github.com/pluginaweek/state_machine) to model the state of pomodori and breaks. Internal event handlers do the actual work. Calling the external hooks is one of these tasks.

Pomodoro:

![State Transition Diagram for Pomodoro](https://rawgithub.com/nerab/paradeiser/master/doc/Paradeiser::Pomodoro_status.svg)

Break:

![State Transition Diagram for Break](https://rawgithub.com/nerab/paradeiser/master/doc/Paradeiser::Break_status.svg)

The graph was created using the rake task that comes with `state_machine`:

    rake state_machine:draw CLASS=Paradeiser::Pomodoro TARGET=doc FORMAT=svg HUMAN_NAMES=true ORIENTATION=landscape
    rake state_machine:draw CLASS=Paradeiser::Break    TARGET=doc FORMAT=svg HUMAN_NAMES=true ORIENTATION=landscape

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
