This is a fork of https://github.com/mavam/trac-hub.git whre I collect
the changes I have made in order to migrate my projects from trac via
github to gitlab.

Major changes are

1.  use docker to run the dependencies (in particular ruby, mysql)
2.  tweak the layout of the ticets according to our taste
3.  transfer some informations to labels and some to the ticket body
    (called badges in the script)
4.  maintain the ticket id even of they are not consequtive in trac. For
    this we create dummy tickets
5.  handle milestones
6.  handle attachments
7.  drive it all by config file. Rename configfile to
    trac-hub.config.yaml; search the config file in the parent folder
    and in the current folder.

# Getting started

## Prerequisites

1.  docker
2.  access to the trac-envionment. Tthis script needs direct access to
    the svn repository as well as the trac-env. It does not use trac
    api.
3.  git
4.  a github account

## how to use it

1.  install docker
2.  create a working folder structure like this

        trac-to-github
          +- trac-env           # this is the trac-environment from the source
          +- trac-hub           # created by git clone of this projct
          +- foobar-git         # the corresponding git repository
                                # created by `git-svn clone <svn-url>/trunk foobar-git` 

3.  clone this project
4.  cd to this project
5.  start mysql by

    'docker-compose up mysql'

    you can then access the database server under `localhosot:3306`

6.  import the trac to a new database on this server, e.g. `foobar`

    ensure the dataase collation

    `ALTER DATABASE`foobar`CHARACTER SET utf8 COLLATE utf8_bin;`

7.  copy the trac environment to a sibling of this project. This will be
    needed to extract the attachments.

8.  create parts for the config file

    `docker-compose run --rm trac-hub -i > x.txt`

9.  create trac-hub.config.yaml`based on`trac-hub.confg.yaml.example\`

10. adjust settings in `trac-hub.config.yaml`. Therby use parts of
    `x.txt`

11. convert the svn to git

    `git-svn clone <svn-url>/trunk foobar-git`

12. create the project on github and push foobar-git by following the
    instructions from github

    ``` {.bash}
    git remote add origin https://github.com/bwl21/foobar.git
    git push -u origin master
    ```

13. create an app key in `https://github.com/settings/apps/new` enter
    the key to `trac-hub.config.yaml`

14. create the revmap by

    `git svn log --show-commit --oneline` foobar-git \> revmap.txt

15. create the attachment exporter

    `docker-compose run --rm trac-hub -A`\
    you will see a message about the crated file

16. now run the converter

    `docker-compose run --rm trac-hub --M -s 0`

17. If something goes wrong, restart the the converter

    `docker-compose run --rm trac-hub --M -s <next free id>`

## Bonus :-)

You can run a trac-instance - without svn - but to inspect details by

    `deocker-compose up tracd`

you can run a gitlab-instance

    'docker-compose up gitlab` 

I managed to import the converted github project in to this local
instance for testing purpoes

## future

May be we can add direct gitlab support to trac-hub

# trac-hub

**trac-hub** converts [trac](http://trac.edgewall.org/) tickets into
github issues. To this end, it accesses trac's underlying database to
create tickets and post the change history of each ticket as comments.

## Synopsis

Copy the [example YAML configuration](config.yaml.example) and adapt it
as needed:

    cp config.yaml.example config.yaml
    vim config.yaml

Thereafter just invoke `trac-hub`:

    ./trac-hub

If this fails with an error, make sure to have a look at the
[Dependencies](#dependencies) section.

By default, trac-hub assumes the file `config.yaml` in the same
directory as the script. You can also specify the configuration file on
the command line:

    ./trac-hub -c foo.yaml

Add the `-v` flag for more verbose output:

    ./trac-hub -v

Add the `-o` flag to only import the tickets that are not in a `closed`
status:

    ./trac-hub -o

To resume the migration at a given trac ticket ID, use `-s`:

    ./trac-hub -s 42

If you want all trac comments/changes to be compiled into a single post
on the github issue:

    ./trac-hub -S

If you migrate to a bare github, you might want want to ensure that the
ticket ids do not change. In this case you can create dummy tikcets
forids missing in trac (because they were deleted). The process might
interrupt, so you can still specify the first number to transfer.

    /trac-hub -M -s 601  

*Note*: when converting your trac setup to github, it is prudent to
first try the migration into a test repository which you can delete
afterwards. If this worked out fine and delivered the expected results,
one can still aim the script at the real repository.

## Issue numbers

By default, trac-hub will verify that the created issue numbers match
the ticket IDs of the corresponding trac ticket and error-exit if the
number is off.

If you need this behaviour, you should also disable user interactions by
setting **Limit to repository collaborators** under your repository
settings. Alternatively, when migrating issues to a new repository,
import the issues on a test-repository and rename the repository to the
final name when the import went satisfactory.

You can disable this check by using the *fast* option:

    ./trac-hub -F

This will also make your import much faster (but after the script has
finished, it can still take some time until the issues are created on
github).

Using this option is obligatory, if you know that the ticket IDs will
not match, e.g. because non-trac tickets already exist. In this case,
you must also specify the ID of the first ticket to be migrated (even if
it is 1):

    ./trac-hub -F -s 1

If you start to import in a fresh github project, trac-hub can create
dummy tickets issue numbers not available in trac. This even works if
you want to run it multiple times. In this case you need to provide -s
for the first id not available in Github.

    ./trac-hub -M    

## Technology

It uses uses github's new [issue import
API](https://gist.github.com/jonmagic/5282384165e0f86ef105) to create
issues

-   without hitting abuse detection warnings and getting blocked
-   without sending email notifications
-   without increasing your contribution count to ridiculous heights
-   much faster than with the [normal issues
    API](https://developer.github.com/v3/issues/)
-   with correct creation/closed date set
-   atomically without users being able to interfere in the creation of
    a single issue

## Configuration

The YAML configuration file contains four sections. The section `trac`
includes all trac-related configuration options. The database URL
follows the scheme described
[here](http://sequel.jeremyevans.net/rdoc/classes/Sequel.html#method-c-connect).
In order to use databases other than sqlite, you may have to add them to
the `Gemfile`. For mysql databases, you should use the mysql2 adapter.

The section `github` includes the repository to migrate as well an API
token which can be generated under [Settings -\> Personal Access
Tokens](https://github.com/settings/tokens).

The section `labels` allows for custom label mappings. Since github's
issue tracker does not have a first-class notion of ticket priority,
type, and version information, trac-hub supports expressing these in the
form of labels.

The section `users` contains a one-to-one mapping between trac usernames
or email addresses and github usernames for users for which no github
credentials are known or can't be used and are thus not stored in the
`github` section. As soon as you have the login credentials for a user
please use the `github` `logins` section in the config instead.

The section `milestones` containes a mapping of milestones as it is
generated by trac-hub -i

The secion `attachments` specifies how you want to grab attachments. In
particular the attachment_uri supports the case that the imagename is
embedded in the uri:

The imagename is built of ticket_id and image filename. `exportfolder`
ist the folder where the images will be downloaded to on the trac
system.

``` {.yaml}

attachments:
  attachment_uri: https://gitlab.com/mynamespace/myrepo/raw/master/from_trac/#imagename#?inline=false
  export_folder: ./attachments
  export_script: attachments.sh
```

https://gitlab.com/pjtadmin/pjtadmin_attach/raw/develop/from_trac/233/screenshot_183.jpg
https://gitlab.com/pjtadmin/pjtadmin_attach/raw/develop/from_trac/233/screenshot_183.jpg
You can use

    trac-hub -i 

to produce a yaml file with labels, users, milestones etc. You can copy
this into the config file and adapt it as required.

it also produces a shell script which in invokes trac-admin to download
the attachments from trac.

## Dependencies

Make sure you have the bundler gem installed (`gem install bundler`).
Thereafter, you can install missing dependencies via `bundle install`.

The easiest way to install the dependencies locally is as follows:

    bundle install --path vendor/bundle

In this case, you can execute the program by replacing `./trac-hub`
above with `bundle exec trac-hub`, e.g.:

    bundle exec trac-hub -s 42

## License

trac-hub comes with a [BSD-style licence](COPYING).
