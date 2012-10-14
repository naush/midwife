## Midwife
A collection of preprocessors for frontend development.

## Install

    $ gem install midwife

## Setup

In Rakefile:

```ruby
require 'midwife'
```

The rest:

    $ rake setup

## Usage

    rake care    # Care for your haml/scss/js
    rake listen  # Listen to your haml/scss/js
    rake serve   # Serve your haml/scss/js
    rake setup   # Setup your environment

---

Make an `assets` folder, and drop your haml, scss and js files in there. Running `rake care` will process haml, scss and js files once, and drop the artifacts into the `public` fodler. Run `rake listen` will process each time you touch the files. Run `rake serve` to start a web server running on [localhost:9292](http://localhost:9292) that listens to every change you make.

## Helpers

```haml
= render "partial" # file name must be prefixed with an underscore, ie. _partial.haml.
```

## Deploy to Heroku

    $ gem install heroku
    $ heroku create app_name
    $ git push heroku master
    $ heroku open
