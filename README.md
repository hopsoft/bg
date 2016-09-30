# Bg

## Non-blocking ActiveRecord method invocation

This library allows you to invoke ActiveRecord instance methods in the background.

* `Bg::Asyncable` uses concurrent-ruby to execute methods in a different thread
* `Bg::Deferrable` uses ActiveJob to execute methods in a background process


## Quickstart

### Setup

```ruby
class User < ApplicationRecord
  include Bg::Asyncable  # uses concurrent-ruby
  include Bg::Deferrable # uses ActiveJob
end
```

### Usage

```ruby
user = User.find(params[:id])
user.do_hard_work       # blocking in-process
user.async.do_hard_work # non-blocking in-process
user.defer.do_hard_work # non-blocking out-of-process background job
user.defer(queue: :low, wait: 5.minutes).do_hard_work
```

## Caveats

Bg leverages [GlobalID](https://github.com/rails/globalid) to marshal ActiveRecord instances across thread & process boundaries.
This means that state is not shared between the main process/thread with the process/thread performing the method.

* Do not depend on lexically scoped bindings when invoking methods with Bg::Deferrable
* Do not pass unmarshallable types as arguments with Bg::Deferrable.
  Follow Sidekiq's [simple parameters](https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-job-parameters-small-and-simple) rule

### Examples

#### Good

```ruby
user = User.find(params[:id])
user.update(name: "new value") # persisted changes will be available in Bg invoked methods

user.async.do_hard_work 1, true, "foo", :bar, Time.now
user.defer.do_hard_work 1, true, "foo"
```

#### Bad

```ruby
user = User.find(params[:id])
user.name = "new value" # in memory changes will not be available in Bg invoked methods

user.async.do_hard_work do
  # this is dangerous... you better know what you're doing
  # best to avoid
end

user.defer.do_hard_work :foo, Time.now # args won't marshal properly

user.defer.do_hard_work do
  # blocks are not supported
end
```
