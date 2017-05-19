trac-hub
========

**trac-hub** converts [trac](http://trac.edgewall.org/) tickets into github
issues. To this end, it accesses trac's underlying database and copies over
milestones, creates tickets, and replays the change history of each ticket.

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

To resume the migration at a given trac ticket ID, use `-s`:

    ./trac-hub -s 42

One can also avoid migration of tickets whose title exists already in the
github issue tracker:

    ./trac-hub -d

*Note*: when converting your trac setup to github, it is prudent to first try
the migration into a test repository which you can delete afterwards. If this
worked out fine and delivered the expected results, one can still aim the
script at the real repository.

Configuration
-------------

The YAML configuration file contains four sections. The section `trac` includes
all trac-related configuration options. The database URL follows the scheme
described [here](http://sequel.jeremyevans.net/rdoc/classes/Sequel.html#method-c-connect).
In order to use databases other than sqlite, you may have to add them to the
`Gemfile`. For mysql databases, you should use the mysql2 adapter.

The section `github` includes the repository to migrate as well as a list of
github account credentials. The latter enables creating issues/comments under
the corresponding github user. If trac-hub cannot map a trac user to a github
user, it defaults to the first account entry. 

The section `labels` allows for custom label mappings. Since github's issue
tracker does not have a first-class notion of ticket priority, type, and
version information, trac-hub supports expressing these in the form of labels. 

The section `users` contains a one-to-one mapping between trac usernames or
email addresses and github usernames for users for which no github credentials
are known or can't be used and are thus not stored in the `github` section. As
soon as you have the login credentials for a user please use the `github`
`logins` section in the config instead.

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
