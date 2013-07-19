# Paradeiser

  _Please note that this project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. As such, Paradeiser actually provides much less functionality than it is described here. Once a major milestone is reached, this README will be updated to reflect the actual status._

Paradeiser is a tool for the [Pomodoro Technique](http://www.pomodorotechnique.com/). It keeps track of the current pomodoro and assists the user in managing active and past pomodori:

* Records finished and cancelled pomodori as well as internal and external interruptions and other events
* Keeps track of the timer for the active pomodoro and the break
* Provides out-of-the-box reports that show details about finished and cancelled pomodori
* Shows information about breaks and interruptions

Paradeiser itself is not concerned with the actual management of tasks. There are plenty of tools for that; the author prefers [TaskWarrior](http://taskwarrior.org/).

## Installation

      $ gem install paradeiser

## Usage

### Start a new pomodoro

      $ pom start

There can only be one active pomodoro or break at a time per user. Therefore, repeatedly calling start will have no effect (other than a warning message).

If a break is still active, it will be stopped before the new pomodoro is started.

### Finish the pomodoro

      $ pom finish
      $ pom stop # alias

If a pomodoro is active, it will be marked as successful after stopping it, regardless of whether the 25 minutes are over or not. If a break is active, it will be stopped. If neither a  pomodoro nor or break are active, a warning message will be printed.

### Record an interruption of the current pomodoro

      $ pom interrupt --external Phone call from boss
      $ pom interrupt --internal "Couldn't stay away from Twitter"

Remaining arguments, if present, will be added to the interrupt as annotation. If no pomodoro is active or interrupted (status is idle or paused), the command will throw an error.

### Resume the pomodoro after an interruption

      $ pom resume

If there is no interrupted pomodoro, the command will throw an error.

### Start a break

      $ pom break [--short | --long]

If a pomodoro is active, it will be stopped. By default the break will either be five minutes long or, after four pomodori within a day, the break will be 30 minutes long. This can be overridden with `--short` or `--long`.

There is no public command to stop a break. Either a new pomodoro is started, which will implicitely stop the break, of the break ends naturally because it is over.

Note that for a single user account (technically, for a `~/.paradeiser` directory), not more than one pomodoro [xor](http://en.wikipedia.org/wiki/Xor) one break can be active at any given time.

### Annotate a pomodoro

      $ pom annotate This was intense, but I am happy about the work I finished.

The annotation will be added to the active or, if none is active, to the most recently finished or cancelled pomodoro. Breaks cannot have annotations. If no text is given, the command throws an error.

### Cancel the pomodoro

      $ pom cancel Just couldn't concentrate anymore.
      $ pom abandon # alias

It will be marked as unsuccessful (remember, a pomodoro is indivisible). If no pomodoro is active or interrupted (status is idle or paused), the command will throw an error. If a break is active, the command will do nothing except printing a warning. Remaining arguments, if present, will be added to the pomodoro as annotation.

### Init Paradeiser

      $ pom init

Creates the `~/.paradeiser` directory, an empty data store and the sample hooks in `~/.paradeiser/hooks`. If `~/.paradeiser` already exists, the command will fail with an error message.

### Location

  * List all locations

        $ pom location
        macbook@01:23:45:67:89:0A "Home Office"
        macbook@45:01:89:0A:67:23 "Starbucks"

  * Show the label of a location

        $ pom location macbook@01:23:45:67:89:0A
         Home Office

  * Show the identifier of a location

        $ pom location "Home Office"
        macbook@01:23:45:67:89:0A

  * Label a location

        $ pom location macbook@01:23:45:67:89:0A "Your Label"

## Low-level commands

We don't want another daemon, and `at` exists. We just tell `at` to call

      pom _stop-break

when the break is over. The underscore convention marks this command as a protected one that is not to be called from outside.

So when `at` calls Paradeiser with this line, the pomodoro or break are over and Paradeiser does all the internal processing related to stopping the break (incl. calling the appropriate hooks, see below).

## Status

      $ pom status # with an active pomodoro
      Pomodoro #2 started at 11:03. 14 minutes remaining.

      $ pom status # with no active pomodoro and a previously finished one
      No pomodoro active. Last pomodoro was finished successfully at 2013-07-16 17.07.

      $ pom status # with no active pomodoro and a previously cancelled one
      No pomodoro active. Last pomodoro was cancelled at 2013-07-16 17.07.

      $ pom status # with no active pomodoro and an active break
      Taking a 5 minute break until 2013-07-16 17.07 (4 minutes remaining).

      $ pom status --short # short status (03:39 remaining in the active pomodoro or break)
      03:39

      $ pom status --format %C-%M:%S # custom status format, similar to date +%Y-%m-%dT%H:%M:%S
      B03:39

      $ pom status --format JSON # output in JSON format
      {
        "status": {
          "type": "break",
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
      1 internal interruptions (27 minutes in total)
      2 external interruptions (2 hours and 28 minutes in total)
      4 breaks (3 short, 1 long; 45 minutes in total)

      Most efficient location: Home Office (2/0/1/0)
      Least efficient location: Coffeshop (1/1/0/2)

      The following locations do not have a label. Assign it with

        $ pom location macbook@01:23:45:67:89:0A "Your Label"

The command defaults to --day. Alternative options are --week, --month or --year. Without a value, the argument assumes the current day / week / month / year. A date can be specified as argument, e.g. `pom report --day=2013-07-18`. Argument values are parsed with [Chronic](http://chronic.rubyforge.org/), which also enables symbolic values like `pom report --month="last month"`.

### Verbose Reports (timesheet)

      $ pom report --verbose
      TODO Ordered list of pomodori and breaks, each with annotations (like a time sheet)

The same options as for regular reports apply.

### Exporting a Report

      $ pom report --weekly --format JSON # weekly report in JSON format
      {
        "TODO": "Specify"
      }

## Output Policy
Paradeiser follows the [Rule of Silence](http://www.faqs.org/docs/artu/ch01s06.html#id2878450). If all goes well, a command will not print any output to `STDOUT`. Reports are excempted from this rule.

Error and warning messages always go to `STDERR`.

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
      notify-send "Break" "$POMODORO_TITLE is over." -u critical

* Displaying a desktop notification on MacOS:

      # ~/.paradeiser/hooks/post-stop
      terminal-notifier-success  -message "$POMODORO_TITLE is over."

`$POMODORO_TITLE` is one of the environment variables set by Paradeiser that provides the context for hooks. See below for the full list of available environment variables.

### Edit a hook

      $ pom edit post-stop

Launches $VISUAL or, if empty, $EDITOR with the given hook.

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

### I18N
Paradeiser uses [I18N](https://github.com/svenfuchs/i18n) to translate messages and localize time and date formats.

## API
The actual storage backend is *not a public API* and may change at any given time. External tools should use the Ruby API instead, or rely on the JSON export.

## Sync
In todays world of distributed devices, synching data is a problem almost every app needs to solve. Paradeiser is no exception - it is very easy to come up with use cases that involve many computers. Maybe the user has different devices (mobile and desktop), maybe the user works in different environments, and wants to record all pomodori into a single system.

There are many potential solutions to this problem:

  1. A centralized server could host a data store (relational database, NoSQL store, etc.)
  1. A shared directory could host a single file and access could be coordinated using lock files
  1. Commercial solutions like the [Dropbox Sync API](https://www.dropbox.com/developers/sync)
  1. Custom solutions like [toystore](https://github.com/jnunemaker/toystore) with a [git adapter](https://github.com/bkeepers/adapter-git)

All of these are too much overhead right now, so the decision was made to keep Paradeiser simple and not implement any sync features. This may me revisited in a later version of the app.

## Location
Recording the location of a pomodoro allows Paradeiser to compare the average count of successful and cancelled pomodori and the number of interruptions by location, so that a report can tell in which environment we get the most work done.

In order to record the current location at the start of the pomodoro, Paradeiser will record the hostname and the MAC address of the default gateway:

* OSX

      arp 0.0.0.0 | head -1 | awk {'print $4'}

* Linux:

      GATEWAY=$(netstat -rn | grep "^0.0.0.0" | cut -c17-31); ping -c1 $GATEWAY >/dev/null; arp -n $GATEWAY | tail -n1 | cut -c34-50

The location is then used to assign a label to one or more hostname@MAC strings, which will be used in a report.

## What about the app's name?
In Austrian German, "Paradeiser" means tomato, of which the Italian translation is pomodoro.
