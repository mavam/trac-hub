trac-hub
========

**trac-hub** converts [trac](http://trac.edgewall.org/) tickets into github
issues. To this end, it accesses trac's underlying database to create tickets
and post the change history of each ticket as comments.

Synopsis
--------

Copy the [example YAML configuration](config.yaml.example) and adapt it as
needed:

    cp config.yaml.example config.yaml
    vim config.yaml

Thereafter just invoke `trac-hub`:

    ./trac-hub

If this fails with an error, make sure to have a look at the
[Dependencies](#dependencies) section.

By default, trac-hub assumes the file `config.yaml` in the same directory as
the script. You can also specify the configuration file on the command line:

    ./trac-hub -c foo.yaml

Add the `-v` flag for more verbose output:

    ./trac-hub -v

Add the `-o` flag to only import the tickets that are not in a `closed` status:

    ./trac-hub -o

To resume the migration at a given trac ticket ID, use `-s`:

    ./trac-hub -s 42

If you want all trac comments/changes to be compiled into a single post on the
github issue:

    ./trac-hub -S

*Note*: when converting your trac setup to github, it is prudent to first try
the migration into a test repository which you can delete afterwards. If this
worked out fine and delivered the expected results, one can still aim the
script at the real repository.

Issue numbers
-------------

By default, trac-hub will verify that the created issue numbers match the
ticket IDs of the corresponding trac ticket and error-exit if the number is
off.

If you need this behaviour, you should also disable user interactions by
setting **Limit to repository collaborators** under your repository settings.
Alternatively, when migrating issues to a new repository, import the issues on
a test-repository and rename the repository to the final name when the import
went satisfactory.

You can disable this check by using the *fast* option:

    ./trac-hub -F

This will also make your import much faster (but after the script has
finished, it can still take some time until the issues are created on github).

Using this option is obligatory, if you know that the ticket IDs will not
match, e.g. because non-trac tickets already exist. In this case, you must
also specify the ID of the first ticket to be migrated (even if it is 1):

    ./trac-hub -F -s 1
    
If you start to import in a fresh github project, trac-hub can create
dummy tickets issue numbers not available in trac. This even works 
if you want to run it multiple times. In this case you need to provide
-s for the first id not available in Github.

    ./trac-hub -M    
    

Technology
----------

It uses uses github's new [issue import
API](https://gist.github.com/jonmagic/5282384165e0f86ef105) to create issues

- without hitting abuse detection warnings and getting blocked
- without sending email notifications
- without increasing your contribution count to ridiculous heights
- much faster than with the [normal issues API](https://developer.github.com/v3/issues/)
- with correct creation/closed date set
- atomically without users being able to interfere in the creation of a single issue

Configuration
-------------

The YAML configuration file contains four sections. The section `trac` includes
all trac-related configuration options. The database URL follows the scheme
described [here](http://sequel.jeremyevans.net/rdoc/classes/Sequel.html#method-c-connect).
In order to use databases other than sqlite, you may have to add them to the
`Gemfile`. For mysql databases, you should use the mysql2 adapter.

The section `github` includes the repository to migrate as well an API token
which can be generated under [Settings -> Personal Access
Tokens](https://github.com/settings/tokens).

The section `labels` allows for custom label mappings. Since github's issue
tracker does not have a first-class notion of ticket priority, type, and
version information, trac-hub supports expressing these in the form of labels.

The section `users` contains a one-to-one mapping between trac usernames or
email addresses and github usernames for users for which no github credentials
are known or can't be used and are thus not stored in the `github` section. As
soon as you have the login credentials for a user please use the `github`
`logins` section in the config instead.

You can use 

```
trac-hub -i 
```

to produce a yaml file with labels, users, milestones etc. You can copy this into
the config file and adapt it as required.


Dependencies
------------

Make sure you have the bundler gem installed (`gem install bundler`).
Thereafter, you can install missing dependencies via `bundle install`.

The easiest way to install the dependencies locally is as follows:

    bundle install --path vendor/bundle

In this case, you can execute the program by replacing `./trac-hub` above
with `bundle exec trac-hub`, e.g.:

    bundle exec trac-hub -s 42

License
-------

trac-hub comes with a [BSD-style licence](COPYING).
