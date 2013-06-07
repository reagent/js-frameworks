# Front-End Framework Exploration

Client-side application frameworks have been around for quite some time and there are a few leaders that have emerged in the space.  In an effort to better understand the strengths & weaknesses of each, I'm helping to lead a class that will explore three major frameworks: [Backbone.js](http://backbonejs.org/), [Ember.js](http://emberjs.com/), and [Angular.js](http://angularjs.org/).

I think that the best way to gain proficiency in any technology is to build an application with it, so this class will explore building a [HackerNews](http://news.ycombinator.com) clone in each framework using an existing API (details below).

## Format

We will spend about 5 months learning these three frameworks, which means that we will dedicate 6 weeks to each framework.  During those 6 weeks, we will meet as a group every other week to demo our applications and help each other out with any problems we encounter.

## Schedule

We'll kick off with Backbone.js on the 17th, and then continue on to the other 2 frameworks.  If people are interested in continuing after the 5 months, we can tackle an additional framework.  I have Ext.js listed here, but we could easily do something like Can.js or something that's more relevant.

Here's the full meeting schedule:

### Backbone.js

* June 17th
* July 1st
* July 15th

### Ember.js

* July 29th
* August 12th
* August 26th

### Angular.js

* September 9th
* September 23rd
* October 7th

### Ext.js or other (optional)

* October 21st
* November 4th
* November 18th

## Breakdown of Functionality

Between meetings, we will be working on building out the functionality of the application in stages.  The list below will serve as a general goal for each 2 week period.

### Weeks 1-2

* Visitors can sign up for an account
* Users can log in to their account (i.e. generate an authentication token)
* Users can update their account information
* Users can view their account information
* Users can post an article
* Visitors can view a list of posted articles

### Weeks 3-4

* Users can up-vote an article
* Users can comment on an article
* Users can reply to a comment
* Users can up-vote a comment
* Visitors can view a single article with threaded comments
* Visitors can view threaded replies to a comment

### Weeks 5-6

* Users can log out (i.e. destroy their authentication token)
* Users can remove a comment they have left
* Users can delete their account
* Users can view a list of articles they have posted
* Users can view a list of the comments they have left

### Extra (as time allows)

* Visitors can view a list of articles a user has posted
* Visitors can view a list of comments a user has left
* Show your 'favorite' articles

## The HackerNews API

As mentioned earlier, we will be interacting with an existing API.  Contained in this repository is a simple API service implemented in Ruby with [Sinatra](http://www.sinatrarb.com/) & [DataMapper](http://datamapper.org/) that is a clone of much of the functionality from the HackerNews site.  It supports all the functionality required to implement the list of features above.

### Using the API Service

First, ensure that you have all the dependencies installed on your machine:

    $ bundle install

Once those are installed, you can start the server:

    $ rackup

By default, this will boot [thin](http://code.macournoyer.com/thin/) on port `9292` that you can then use as the API server for your client-side application.  If you're starting this up for the first time, you might want to run the test suite to ensure everything is working properly:

    $ ./bin/test

That test suite will generate a bunch of data in your development database, if you want to reset it after the test runs, just delete the database and restart the server:

    $ rm app/db/*.sqlite3 && rackup

### Connecting to the API

This is a simple JSON API that supports HTTP GET / POST / PUT / DELETE operations. When connecting, you must send the proper `Content-Type` header:

    $ curl -i -H "Content-Type: application/json" "http://localhost:9292/articles"

When performing a PUT or POST operation, you must send the request body as JSON:

    $ curl -i \
        -H "Content-Type: application/json" \
        -d '{"username":"user","email":"user@host.com","password":"password","password_confirmation":"password"}' \
        "http://localhost:9292/users"

    $ curl -i \
        -H "Content-Type: application/json" \
        -H "X-User-Token: 123deadbeef" \
        -X PUT \
        -d '{"email":"new_email@host.com"}' \
        "http://localhost:9292/account"

### Authentication

For actions that require a user's credentials, the API uses a simple token-based authentication scheme.  To retrieve a token, you'll need to log in:

    $ curl \
        -H "Content-Type: application/json" \
        -d '{"email":"user@host.com","password":"password"}' \
        "http://localhost:9292/session"

      -> {"token":"f9c0bd9258424b5cef7c05138e07ff3fc6f76027"}

Once you have a valid token, you can use that for subsequent API requests:

    $ curl \
        -H "Content-Type: application/json" \
        -H "X-User-Token: f9c0bd9258424b5cef7c05138e07ff3fc6f76027" \
        -d '{"title":"Viget Extend Blog","url":"http://viget.com/extend"}' \
        "http://localhost:9292/articles"

      -> {"id":3,"title":"Viget Extend Blog","url":"http://viget.com/extend"}

Failure to provide a token for an action that requires authentication will return HTTP status code 401 (Unauthorized) along with an error message:

    $ curl -i \
        -H "Content-Type: application/json" \
        -d '{"title":"Viget Extend Blog","url":"http://viget.com/extend"}' \
        "http://localhost:9292/articles"

        HTTP/1.1 401 Unauthorized
        Content-Type: application/json
        Content-Length: 41
        Connection: keep-alive
        Server: thin 1.5.0 codename Knife

        {"errors":["Authentication is required"]}

### Endpoints

A full list of supported endpoints is below.  Some general guidelines:

* GET operations are used to fetch a resource or collection of resources and return 200 (OK) on success
* POST operations are used to create resources and return a status of 201 (Created) on success
* PUT operations update existing resources and return 200 (OK) on success
* DELETE operations remove resources and return 200 (OK) on success
* GET / POST / PUT operations return a JSON representation of the resource on success
* All operations return 400 (Bad Request) on error and return a JSON representation of the errors

Note: endpoints marked with an asterisk (`*`) require authentication.

#### Users

     Create: POST   /users
      Fetch: GET    /users/:id
     *Fetch: GET    /account
    *Update: PUT    /account
    *Delete: DELETE /account

#### Authentication

      Login: POST   /session
    *Logout: DELETE /session

#### Articles

       List: GET  /articles
    *Create: POST /articles
       List: GET  /users/:id/articles
      *List: GET  /account/articles
      Fetch: GET  /articles/:id
      Fetch: GET  /account/favorites

#### Comments

       List: GET    /users/:id/comments
      *List: GET    /account/comments
       List: GET    /articles/:id/comments
    *Create: POST   /articles/:id/comments
       List: GET    /comments/:id/comments
    *Create: POST   /comments/:id/comments
      Fetch: GET    /comments/:id
    *Delete: DELETE /comments/:id

#### Votes

    *Create: POST   /articles/:id/votes
    *Create: POST   /comments/:id/votes

### Interacting With The Application

If you need to inspect the resources created by the API or why something isn't working the way you expect it to, you can use the simple console to interact with the data:

    $ ./bin/console

    > Token.all
     => [#<Token @user_id=1 @value="f9c0bd9258424b5cef7c05138e07ff3fc6f76027">]
    > Token.first.user
     => #<User @id=1 @email="user@host.com" @username="user_1", ...>
