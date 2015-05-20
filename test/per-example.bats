#!/usr/bin/env bats
# Per example tests
#
# This test compares outputs of various modes of ddlog against a .ddl example file with its expected output.
# Test is skipped if no expected output is found.

# required variables
: ${DDLOG_JAR:?path to ddlog jar}
: ${EXAMPLE:?path to input ddlog program}
EXAMPLE_BASEPATH=${EXAMPLE%.ddl}
EXAMPLE_NAME=${EXAMPLE_BASEPATH##*/}

# some preconditions
setup() {
    [ -e "$DDLOG_JAR" ]
    [ -e "$EXAMPLE" ]
}

## tests for basic compilation and pretty-printing

# compare the compiled output with what's expected
@test "compile $EXAMPLE_NAME" {
    expectedOutput=$EXAMPLE_BASEPATH.compile.expected
    [ -e "$expectedOutput" ] || skip
    scala "$DDLOG_JAR" compile "$EXAMPLE" |
    diff -u "$expectedOutput" -
}

# compare the pretty-printed output with what's expected
@test "print $EXAMPLE_NAME as expected" {
    expectedOutput=$EXAMPLE_BASEPATH.print.expected
    [ -e "$expectedOutput" ] || skip
    scala "$DDLOG_JAR" print "$EXAMPLE" |
    diff -u "$expectedOutput" -
}

# check if print is idempotent
@test "print $EXAMPLE_NAME is idempotent" {
    printed=$BATS_TMPDIR/ddlog-$EXAMPLE_NAME-printed.ddl
    scala "$DDLOG_JAR" print "$EXAMPLE" >"$printed" || skip
    scala "$DDLOG_JAR" print "$printed" |
    diff -u "$printed" -
}


## tests for --incremental support

# compare the compiled output of the incremental version with what's expected
@test "print $EXAMPLE_NAME as expected" {
    expectedOutput=$EXAMPLE_BASEPATH.compile-incremental.expected
    [ -e "$expectedOutput" ] || skip
    scala "$DDLOG_JAR" compile --incremental "$EXAMPLE" |
    diff -u "$expectedOutput" -
}

# compare the pretty-printed output of the incremental version with what's expected
@test "print $EXAMPLE_NAME as expected" {
    expectedOutput=$EXAMPLE_BASEPATH.print-incremental.expected
    [ -e "$expectedOutput" ] || skip
    scala "$DDLOG_JAR" print --incremental "$EXAMPLE" |
    diff -u "$expectedOutput" -
}

