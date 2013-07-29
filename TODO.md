# Paradeiser Implementation TODOs

* Scope the id to the day by introducing a key class the is an aggregate of day and id.
  - The view only shows the id for any given day in most reports.
  - We still want to have a global identity for a pomodoro (withing the realm of a single user).

* Add minimal tests for the `pom` bin so that we don't have to create a lot of processes.
  - Only test behavior that cannot be tested in a controller test, like exit codes.

* Print only the id of the just-modified pom when not running in a tty
  - test with `if $stdin.tty?`
  - If that approach works well, suggest it for tw too (bulk actions, e.g. In scripts)

* With the first release, reduce the README. Move features that are not implemented yet away from the README, into either
  - the doc folder as individual files, or
  - github issues as feature (allows discussion).

  When a feature is done, move it to a doc file (not the readme; it's getting too big) or a wiki page.

* Make an [ASCII cast](http://ascii.io/) about paradeiser
  - Tell tw people about paradeiser dep:parent
  - Tell pomodoro people about paradeiser dep:parent
