# Paradeiser Implementation TODOs

* Roll back what I did with the quiet switch because some if you really want to be quiet you can always go back to redirect and send it to the /dev/null. By impl quiet you just reimplement shell redirection. We can't roll back the whole thing because there was another change in the commits but at least we can remove --quiet again.

* The controller tests actually test the view, too. This is too much, so we need to split them. Asserting the variables set by the controllers should do (potentially passing the controller's binding)

* Commands enqueued with `at need to be added the uuid of the pom to work on; otherwise they could modify the wrong thing.

  Example:

      `pom break --long` # will enqueue `pom break end` for in 30 minutes

      # 5 minutes later
      `pom start` # silently ends the break

      # 2 minutes later
      `pom cancel`
      `pom break`

      # Note that the first `pom break end` is still enqueued. It will cancel the last one, which is certainly not what we want.

  We need to either enqueue the ID of the break with the command

    pom break djvkd-gn358-j38kfk... end

  or cancel all enqueued commands with the `pom cancel`. This ois probably the better option as we deciced to have one break or pomodoro at a time anyway.

* Implement `pom init` to make the directory (copying hooks can come later)

* Improve status messages with relative times and dates (`distance_of_time_in_words_to_now`)

* Implement report as defined in the README

* `pom log` could allow logging pomodoro after the fact.

* Do we need a config file, and if so, should it be a user-editable file? Probably.

  If so, a config controller is on order.

* A text-based repo format would be much more UNIX-like. Think about a JSON repo. Loading it could share a lot of code with import (which we will need anyway). And we cannot trust a JSON repo any more than an import file.

* Rename `pom end-break` to `pom break end` and allow `pom break start` to be the same as `pom break`

* Have the router catch warnings (those errors that extend Warning) and print the message to STDERR, but do not exit. The actual exit code is still determined by the controller.

* If the `at` command is not available or not enabled, print a warning and continue. The program will still be useful.

* In tests, stub `at` via stubbing `Kernel#exec` in order to
  - simulate the `at` command, and
  - simulate the case that `at` is missing

* Check the queue after enqueing a job.
  - Warn if the job just added is not there.
  - With the trace option, print the job id and instructions to look at the `at` queue.

* `pom doctor` checks if `at` is there and enabled. Provides a hint what to do if not.

* `pom init` warns if `at` is not there or not enabled (e.g. on the Mac)

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
  - Tell the TaskWarrior community about Paradeiser
  - Tell the Pomodoro community about Paradeiser
  - Tell the Ruby community about Paradeiser (e.g. @neverbendeasy does kanban)
