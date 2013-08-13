# Paradeiser Backlog

* Add status message and -code tests for break

* Whenever par runs, it should garbage-collect pomodori or breaks (finish them and adjust their finish time) that weren't finished after they were over (e.g. because at isn't there or the hooks did not fire)

* Cancel all enqueued commands on `pom break`, just like with `pom start`. Otherwise commands already enqueued to `at` would accidentially change a newer thing while thinking of operating on the older thing. This is safe (and required) because of Rule #1.

* Abbreviate commands with the Abbrev module

* Implement interrupts

* Implement `pom annotate` and annotations for most commands

* Improve status messages with relative times and dates (`distance_of_time_in_words_to_now`)

* POM_ID is not available to `*-start` hooks because the pomodoro wasn't saved yet. We could either assign it before saving it or allow saving idle pomodori.

* A text-based repo format would be much more UNIX-like. Think about a JSON repo. Loading it could share a lot of code with import (which we will need anyway). And we cannot trust a JSON repo any more than an import file.

* Make `start` the default subcommand for `pom break`, so that `pom break` is the same as `pom break start`.

* Have the router catch warnings (those errors that extend Warning) and print the message to STDERR, but do not exit. The actual exit code is still determined by the controller.

* Add more tests for the scheduler (error cases like no access, or job not added due to other issues)

* With the --trace option, print the job id and instructions to look at the `at` queue after enqueing a job. Also, print if a hook wasn't found or was found, but is not executable.

* Scope the id to the day by introducing a key class the is an aggregate of day and id.
  - The view only shows the id for any given day in most reports. That means that a day (current by default, others in queries or import) is the scope of a pomodoro id.
  - We don't have to globally identify pomodori with uuids because of rule #1

  This also makes `pom import` simple - only if there is nothing on record for the time between the start and end times of the imported thing, it is accepted into our system.

  Deleting or overwriting existing pomodori is not supported. Manual editing, if ever needed, can be done with exporting, deleting the db file, fixing up the exported file, and importing it into a fresh $POM_DIR.

  Active pomodori or breaks are not exported or imported.

* Use Highline#color to color output pro:Paradeiser
  - Status: red/green/yellow
  - Errors red, warnings yellow, otherwise white
  - Turn off when running w/o tty and when --no-color is given

* Print only the id of the pom that was just created / modified / queried when not running in a tty
  - test with `if $stdin.tty?`
  - If that approach works well, suggest it for TaskWarrior too (for bulk actions, e.g. in scripts)

* Implement documentation Approach
  - `pom help` is what the user will use to get information.
  - Not sure how to allow the user to look at features that are not related to a command. Either extend `pom help` to accept arbitrary keywords, or look into 'gem man`.

  Development Tasks

  - Describe each feature / command in one md file (alternatively, store at GitHub issues as feature, would allow discussion).
  - When a feature is done, move it to a doc file (not the readme; it's getting too big) or a wiki page.
  - `pom help <command>` consumes the feature files.
  - Feature files could be exported onto a the github wiki or static pages about Paradeiser.
  - As part of finishing a feature, the feature file is moved from the backlog file to in individual doc file, and the README is updated to mention that feature.

* Promote Paradeiser
  - Publish an [ASCII cast](http://ascii.io/)
  - Tell the TaskWarrior community about Paradeiser
  - Tell the Pomodoro community about Paradeiser
  - Tell the Ruby community about Paradeiser (e.g. @neverbendeasy does kanban)
