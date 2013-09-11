chef-browser
============

Run `$ rackup config.ru`

Refactoring: needs loads of tidying up, for example:
- right now each `erb` file creates a new Ridley server instance once it's opened, together with all other handy instance variables. This should be extracted in a separate file and not copied. Has effect on page loading time, especially with bigger servers;
- reorganizing data: lots of temporary files at the moment, not the best UI & UX;
- indentation (!).
