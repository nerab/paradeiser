# Paradeiser Implementation TODOs

* Change the behavior of `pom status` to be verbose by default and add --quiet to this command alone. Make sure that --quiet wins over --verbose, or throw.

* Rename `pom end-break` to `pom break end`

* Router catches warnings (those that extend Warning) and prints to stderr, but does not exit. Exit code still comes from the controller.

* If `at` is not there or not enabled, print warning, but continue. Still useful.

* Stub kernel.exec in tests to simulate missing at.

* Check the queue after enqueing a job. Warn if not there. With trace, print the job id.

* `pom doctor` checks that `at` is there and enabled. Provides a hint what to do if not.

* `pom init` warns if `at` is not there or not enabled (mac)

* Scope the id to the day by introducing a key class the is an aggregate of day and id.
  - The view only shows the id for any given day in most reports.
  - We still want to have a global identity for a pomodoro (withing the realm of a single user).

* Add minimal tests for the `pom` bin so that we don't have to create a lot of processes.
  - Only test behavior that cannot be tested in a controller test, like exit codes.

* Print only the id of the pom that was just created / modified / queried when not running in a tty
  - test with `if $stdin.tty?`
  - If that approach works well, suggest it for TaskWarrior too (bulk actions, e.g. In scripts)

* With the first release, reduce the README. Move features that are not implemented yet away from the README, into either
  - the doc folder as individual files, or
  - github issues as feature (allows discussion).

  When a feature is done, move it to a doc file (not the readme; it's getting too big) or a wiki page.

* Promote Paradeiser
  - Publish an [ASCII cast](http://ascii.io/)
  - Tell TaskWarrior community about Paradeiser
  - Tell Pomodoro community about Paradeiser
  - Tell Ruby community (e.g. @neverbendeasy does kanban) about Paradeiser
