trac-hub
========

**trac-hub** converts [trac](http://trac.edgewall.org/) tickets into github
issues. To this end, it accesses trac's underlying database and copies over
milestones, creates tickets, and finally replays the change history of each
individual ticket.

Synopsis
--------

Let's consider `user/test` the test repository for this example. Copy the
[example YAML configuration](config.yaml.example) and adapt it as needed:

    cp config.yaml.example config.yaml
    vim config.yaml

Thereafter simply run `trac-hub` with the YAML config as follows:

    ./trac-hub -c config.yaml

You can also add the `-v` flag for more verbose output.

**Note**: when converting your trac setup to github, it is prudent to first try the
migration into a test repository, and if this worked out fine, then
parameterize the script to point to the real repository.

Configuration
-------------

The YAML configuration file contains four sections. The section `trac` includes
all trac-related configuration options. At this point trac-hub only supports
SQLite, but it would be trivial to add PostgreSQL and MySQL support.

The section `github` includes your github login credentials and the repository
in which to migrate. Note that all issues and comments will use the provided
username.

The section `labels` allows for custom label mappings. Since github's issue
tracker does not have a first-class notion of ticket priority, type, and
version information, trac-hub supports expressing these in the form of labels. 

The section `users` contains a one-to-one mapping between trac usernames and
github usernames. Each github username must be an authorized collaborator with
push privileges; trac-hub ignores unauthorized mappings.

License
-------

trac-hub comes with a [BSD-style licence](COPYING).
