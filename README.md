# Paradeiser

  _Please note that this tool is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. As such, in reality, *Paradeiser* provides much less functionality yet than it is described here. Once a major milestone is reached, this README will be updated to reflect the actual status._

*Paradeiser* is a tool for the [Pomodoro Technique](http://www.pomodorotechnique.com/). It keeps track of the current pomodoro and assists the user in managing active and past pomodori:

* Records finished and cancelled pomodori as well as internal and external interruptions and other events
* Keept track of the timer for the active pomodoro and the break
* Provides out-of-the-box reports that show details about finished and cancelled pomodori
* Shows information about breaks and interruptions

*Paradeiser* itself is not concerned at all with the actual task management. There are plenty of tools for that; the author prefers [TaskWarrior](http://taskwarrior.org/).

## Installation

      $ gem install paradeiser

## Usage

### Start a new pomodoro

      $ pom start

Note that there can only be one active pomodoro (or a break) at a time.

### Finish the pomodoro

      $ pom finish
      $ pom stop # alias

It will be marked as successful, regardless of whether the 25 minutes are over or not.

### Record an interruption of the current pomodoro

      $ pom interrupt --external
      $ pom interrupt --internal

### Resume the pomodoro after an interruption

      $ pom resume

### Start a break

      $ pom break

By default the break will be five minutes long. Only after four pomodori within a day, the break will be 30 minutes long.

Note that for a single user account, not more than one pomodoro [xor](http://en.wikipedia.org/wiki/Xor) one break can be active at any given time.

### Cancel the pomodoro

      $ pom cancel
      $ pom abandon # alias

It will be marked as unsuccessful (remember, a pomodoro is indivisible).

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

      $ pom report # defaults to --daily, alternative options are --weekly | --monthly | --yearly (exclusively)
      Daily Pomodoro Report for 2013-07-16

      3 pomodori finished
      1 pomodoro cancelled
      1 internal interruptions
      2 external interruptions
      4 breaks (3 short, 1 long)

      $ pom report --weekly --format JSON # weekly report in JSON format
      {
        "TODO": "Specify"
      }

## Output Policy
*Paradeiser* follows the [Rule of Silence](http://www.faqs.org/docs/artu/ch01s06.html#id2878450). If all goes well, a command will not print any output to `STDOUT`. Reports are excemted from this rule.

Error messages always go to `STDERR`.

## Hooks
Instead of handling tasks itself, *Paradeiser* integrates with external tools via hooks. Every event will attempt to find and execute an appropriate script in ~/.paradeiser/hooks/. Sufficient information will be made available via environment variables.

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
* `post-break` is called after the timer of the current break fired (the break is over), but before internal processing for the `break` action begins

Terms: Commands are invoked by the user (e.g. `pom start`). Actions are what Paradeiser does internally.

Examples for the use of hooks are:

* Displaying a desktop notification on `pre-finish`
* tmux status bar integration like [pomo](https://github.com/visionmedia/pomo) by writing the status to `~/.pomo_stat` from the `post-` hooks.

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
*Paradeiser* uses a [state machine](https://github.com/pluginaweek/state_machine) to model a pomodoro. Internal event handlers do the actual work; among them is the task of calling the external hooks.

#### Pomodoro

  IDLE => ACTIVE => FINISHED

  IDLE => ACTIVE => CANCELLED

  IDLE => ACTIVE => INTERRUPTED => ACTIVE => FINISHED

  IDLE => ACTIVE => INTERRUPTED => CANCELLED

#### Break
A break cannot be interrupted or cancelled.

  IDLE => ACTIVE => FINISHED

### I18N
*Paradeiser* uses [I18N](https://github.com/svenfuchs/i18n) to translate messages and localize time and date formats.

## API
External tools should use the Ruby API instead or rely on the JSON export. The actual storage backend is **not a public API** and may change at any given time.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## What about the name?
In Austrian German, "Paradeiser" means tomato, of which the Italian translation is pomodoro.
