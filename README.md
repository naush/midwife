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

- `rake care` processes `haml`, `scss` and `js` files once, and drops the artifacts in `public`.
- `rake listen` processes each time you touch the files.
- `rake serve` starts a web server running on [localhost:9292](http://localhost:9292) and listens to every change you make.
- `rake setup` sets up your environment.
- `rake stitch` composes `png` files in `assets/images` into a single file and drop it in `public/images`, as well as creates a complimentary partial `_sprites.scss` in `assets/stylesheets`, which you can import into your scss.

## Helpers

```haml
= render "partial" # file name must be prefixed with an underscore, ie. _partial.haml.
```

## Deploy to Heroku

    $ gem install heroku
    $ heroku create app_name
    $ git push heroku master
    $ heroku open

## Example

- [manifesto_front](https://github.com/naush/manifesto_front)