## 2.0.0, 2018-04-19

* [BREAKING] Dropped support for older Rubies. The only supported Ruby versions are 2.4.3 and 2.5.0.
* Updated dependencies.
* Switched the base Dockerfile image to ruby:2.5.
* [bugfix] Non-UTF-8 characters in cookbook files won't raise an error anymore.
* [bugfix] Incomplete cookbook metadata won't raise an error when trying to view a cookbook.
* [testing] Rubocop is now part of the test suite.

##1.1.1, 2015-02-05

* [bugfix] Links to individual recipes listed in a run list are no longer broken

##1.1.0, 2014-10-15

* Adds a cookbook feature:
  - browse cookbooks,
  - view cookbook details,
  - display and download cookbook files.

##1.0.2, 2014-09-10

* [bugfix] A role's run list is no longer sorted.
* Adds a Dockerfile.

##1.0.1, 2013-12-17

* Fixes extensive memory use using Ridley's partial searches
* Adds fuzzy searches, as seen in knife

##1.0.0, 2013-12-11

* Released!
