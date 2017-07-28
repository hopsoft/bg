[![Lines of Code](http://img.shields.io/badge/lines_of_code-117-brightgreen.svg?style=flat)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Code Status](http://img.shields.io/codeclimate/github/hopsoft/bg.svg?style=flat)](https://codeclimate.com/github/hopsoft/bg)
[![Dependency Status](http://img.shields.io/gemnasium/hopsoft/bg.svg?style=flat)](https://gemnasium.com/hopsoft/bg)
[![Build Status](http://img.shields.io/travis/hopsoft/bg.svg?style=flat)](https://travis-ci.org/hopsoft/bg)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/bg.svg?style=flat)](https://coveralls.io/r/hopsoft/bg?branch=master)
[![Downloads](http://img.shields.io/gem/dt/bg.svg?style=flat)](http://rubygems.org/gems/bg)

# Bg

[![Sponsor](https://app.codesponsor.io/embed/QMSjMHrtPhvfmCnk5Hbikhhr/hopsoft/bg.svg)](https://app.codesponsor.io/link/QMSjMHrtPhvfmCnk5Hbikhhr/hopsoft/bg)

## Non-blocking ActiveRecord method invocation

This library allows you to invoke ActiveRecord instance methods in the background.

* `Bg::Asyncable` uses concurrent-ruby to execute methods in a different thread
* `Bg::Deferrable` uses ActiveJob to execute methods in a background process


## Quickstart

### Setup

```ruby
class User < ApplicationRecord
  include Bg::Asyncable::Behavior  # uses concurrent-ruby
  include Bg::Deferrable::Behavior # uses ActiveJob
end
```

### Usage

```ruby
user = User.find(params[:id])

# blocking in-process
user.do_hard_work

# non-blocking in-process separate thread
user.async.do_hard_work

# non-blocking out-of-process background job
user.defer.do_hard_work
user.defer(queue: :low, wait: 5.minutes).do_hard_work
```

## Deferrable

`Bg::Deferrable` leverages [GlobalID::Identification](https://github.com/rails/globalid) to marshal ActiveRecord instances across process boundaries.
This means that state is not shared between the main process & the process actually executing the method.

* __Do not__ depend on lexically scoped bindings when invoking methods.
* __Do not__ pass unmarshallable types as arguments.
  `Bg::Deferrable` will prepare arguments for enqueuing, but best practice is to follow
  Sidekiq's [simple parameters](https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-job-parameters-small-and-simple) rule.

### Examples

#### Good

```ruby
user = User.find(params[:id])
user.defer.do_hard_work 1, true, "foo"
```

#### Bad

```ruby
user = User.find(params[:id])
# in memory changes will not be available in Bg::Deferrable invoked methods
user.name = "new value"

# args may not marshal properly
user.defer.do_hard_work :foo, Time.now, instance_of_complex_type

user.defer.do_hard_work do
  # blocks are not supported
end
```

## Asyncable

`Bg::Asyncable` disallows invoking methods that take blocks as an argument.

* __Important:__ It's your responsibility to protect shared data between threads

### Examples

#### Good

```ruby
user = User.find(params[:id])
user.name = "new value"
user.async.do_hard_work 1, true, "foo"
user.async.do_hard_work :foo, Time.now, instance_of_complex_type
```

#### Bad

```ruby
user = User.find(params[:id])

user.async.do_hard_work do
  # blocks are not supported
end
```

