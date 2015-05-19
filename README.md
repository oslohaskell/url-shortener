Simple URL Shortener Web App
----------------------------

Simple URL shortener using [Scotty](http://hackage.haskell.org/package/scotty)
that was written at the 18 May Osλo Haskell meetup.

To get this up and running, first create a sandbox:

    $ cabal sandbox init

To install the `sqlite-simple` dependency, you will need to install sqlite and
its headers. (E.g. for OS X, run `brew install sqlite`.)

We can then install the dependencies, create the database and run the app:

    $ cabal install --only-dependencies
    $ sqlite3 mapping.db 'CREATE TABLE mapping (key text PRIMARY KEY, url text);'
    $ cabal run

You should then be able to open `http://localhost:3000` in your web browser.

A good way to make changes and quickly test them is to run `cabal repl` and
then use `:edit` to open the file in your `$EDITOR`. You can then run `main` by
typing `main` and pressing enter.

Things that should probably be improved:

- Prepend `http://` if the provided URL does not start with `http://` or
  `https://`
- Make it less ugly :)
- Use something like [persistent](http://www.yesodweb.com/book/persistent)
  instead of `sqlite-simple`.

For an example of a web app that's very similar to this, with fewer rough
edges, see <https://github.com/ehamberg/9m>.

Links to documentation:

- [Scotty](http://hackage.haskell.org/package/scotty)
- [SQLite-Simple](https://hackage.haskell.org/package/sqlite-simple)
- [Hamlet](http://www.yesodweb.com/book/shakespearean-templates)
