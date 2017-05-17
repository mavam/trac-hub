#! /bin/zsh
# Reports existing labels and users in the database. You can use this to create
# corresponding labels on github and setup an authors map.

MYSQL=(mysql -h HOST --port PORT -u USER --password=PASSWORD DATABASE)

section() {
    echo
    echo "====${1//?/=}===="
    echo "=== $1 ==="
    echo "====${1//?/=}===="
}

section AUTHORS
(
    $MYSQL -e "select distinct reporter from ticket;"               | tail -n+2
    $MYSQL -e "select distinct author   from ticket_change;"        | tail -n+2
    $MYSQL -e "select distinct newvalue from ticket_change where field=\"reporter\";"| tail -n+2
    $MYSQL -e "select distinct author   from wiki;"                 | tail -n+2
    $MYSQL -e "select distinct author   from revision;"             | tail -n+2
    $MYSQL -e "select distinct author   from report;"               | tail -n+2
    $MYSQL -e "select distinct author   from attachment;"           | tail -n+2
) | sort -u


section MILESTONE
$MYSQL -e "select distinct milestone    from ticket;"               | tail -n+2
section TYPE
$MYSQL -e "select distinct type         from ticket;"               | tail -n+2
section COMPONENT
$MYSQL -e "select distinct component    from ticket;"               | tail -n+2
section PRIORITY
$MYSQL -e "select distinct priority     from ticket;"               | tail -n+2
section VERSION
$MYSQL -e "select distinct version      from ticket;"               | tail -n+2
section RESOLUTION
$MYSQL -e "select distinct resolution   from ticket;"               | tail -n+2
section SEVERITY
$MYSQL -e "select distinct severity     from ticket;"               | tail -n+2
