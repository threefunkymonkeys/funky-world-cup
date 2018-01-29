## Funky World Cup

[Funky World Cup](http://funkyworldcup.com) is a match predictions website for the FIFA World Cup, that allows you to create groups so you can play with your friends defining prices.

To play on it, you just need an account on Facebook or Twitter. As stated in the disclaimer page, it uses your social network account just for log-in purposes. It doesn't play with your data nor posts in your behalf.

[Funky World Cup](http://funkyworlcup.com) is open source, so you can collaborate or base your work on it.


### How to collaborate

There are two ways of collaboration:

* Reporting issues

  Go to the [issues list](https://github.com/threefunkymonkeys/funky-world-cup/issues?milestone=2&page=1&state=open) on Github and report a bug or a feature request.

  We then will review it and fix it or add the feature request if fits the project.

  When creating issues, please be specific and detailed about what your reporting. Keep in mind that the person that will work on it doesn't have the context you have, haven't seen what youve seen prior to reporting it, and might have no idea what you're talking about, so be clear and descriptive. Attach screenshots if necessary.

* Getting your hands dirty and sumbitting patches

  Fork the repo into your own account, create a branch with a relevant name that describes what the modifications in that branch do and send us a pull request.

  If you work in some of [issues from the backlog](https://github.com/threefunkymonkeys/funky-world-cup/issues?milestone=2&state=open), the suggested branch name is:

  ```
  IssueID-issue_title_or_brief_relevant_description
  ```

  For example:

  ```
  98-new_group_does_not_appear
  ```

  This is a real use case, reported on its [corresponding issue](https://github.com/threefunkymonkeys/funky-world-cup/issues/98).


### Installation

#### Web Application

The application is built on Ruby, using [Cuba](http://www.cuba.is) and a [PostgresSQL](http://postgresql.org) database.

The gem dependency is handled by the [dep](http://rubygems.org/gems/dep) gem, so the first thing you have to do is install it

```
gem install dep
```

Once installed, you need to install your dependencies, which are listed in the `.gems` and `.gems-test` files:

```
dep install
```

####Database

You need two databases, one for tests and one for your development environment.

Create the databases using your preferred method, either using psql or some GUI tool like [pgAdmin](http://www.pgadmin.org)

```
CREATE ROLE funkywc WITH LOGIN CREATEDB PASSWORD 'funkywc';
CREATE DATABASE funky_wc_dev WITH OWNER funkywc ENCODING 'utf8';
CREATE DATABASE funky_wc_test WITH OWNER funkywc ENCODING 'utf8';
```

### Setup

Once you have everything installed and your database created you need to set up the application.

First, copy the settings sample file:

```
cp config/settings{.sample,}.yml
```

Then edit the settings file to setup your database access with the database name and credentials you used in the *Database* step.

Once the database access is set, run the migrations to create the database structure:

```
rake db:migrate
```

Then, seed the database with the teams and matches for the FIFA World Cup 2014

```
rake db:seed
```

Now you have everything you need to start the application:

```
rackup
```

This will put an app server up and running in port 9292 by default, open your browser and point it to http://localhost:9292, you should be able to run the application.

#### Development environment

If your planning on playing around with the code, you might want to run the tests, for this you need to install the tests gem dependencies:

```
dep install -f .gems-test
```

Then, prepare the database:

```
rake db:test:prepare
```

This will clone the development database schema into the test database to keep it synchronized. Then run the tests:

```
rake test:all
```

You can also use the `shotgun` gem to run the application which allows you to make changes and see them without having to restart the app server:

```
gem install shotgun

shotgun -p 9292
```

The `shotgun` gem will make the server to listen in the port `9393` by default, with the `-p` flag you can specify the port of your preference.
