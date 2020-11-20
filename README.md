# Global ID - Reference models by URI

A Global ID is an app wide URI that uniquely identifies a model instance:

  gid://YourApp/Some::Model/id

This is helpful when you need a single identifier to reference different
classes of objects.

One example is job scheduling. We need to reference a model object rather than
serialize the object itself. We can pass a Global ID that can be used to locate
the model when it's time to perform the job. The job scheduler doesn't need to know
the details of model naming and IDs, just that it has a global identifier that
references a model.

Another example is a drop-down list of options, consisting of both Users and Groups.
Normally we'd need to come up with our own ad hoc scheme to reference them. With Global
IDs, we have a universal identifier that works for objects of both classes.


## Usage

Mix `GlobalID::Identification` into any model with a `#find(id)` class method.
Support is automatically included in Active Record.

```ruby
person_gid = Person.find(1).to_global_id
# => #<GlobalID ...

person_gid.uri
# => #<URI ...

person_gid.to_s
# => "gid://app/Person/1"

GlobalID::Locator.locate person_gid
# => #<Person:0x007fae94bf6298 @id="1">
```

### Signed Global IDs

For added security GlobalIDs can also be signed to ensure that the data hasn't been tampered with.

```ruby
person_sgid = Person.find(1).to_signed_global_id
# => #<SignedGlobalID:0x007fea1944b410>

person_sgid = Person.find(1).to_sgid
# => #<SignedGlobalID:0x007fea1944b410>

person_sgid.to_s
# => "BAhJIh5naWQ6Ly9pZGluYWlkaS9Vc2VyLzM5NTk5BjoGRVQ=--81d7358dd5ee2ca33189bb404592df5e8d11420e"

GlobalID::Locator.locate_signed person_sgid
# => #<Person:0x007fae94bf6298 @id="1">
```

**Expiration**

Signed Global IDs can expire some time in the future. This is useful if there's a resource
people shouldn't have indefinite access to, like a share link.

```ruby
expiring_sgid = Document.find(5).to_sgid(expires_in: 2.hours, for: 'sharing')
# => #<SignedGlobalID:0x008fde45df8937 ...>

# Within 2 hours...
GlobalID::Locator.locate_signed(expiring_sgid.to_s, for: 'sharing')
# => #<Document:0x007fae94bf6298 @id="5">

# More than 2 hours later...
GlobalID::Locator.locate_signed(expiring_sgid.to_s, for: 'sharing')
# => nil
```

**In Rails, an auto-expiry of 1 month is set by default.** You can alter that deal
in an initializer with:

```ruby
# config/initializers/global_id.rb
Rails.application.config.global_id.expires_in = 3.months
```

You can assign a default SGID lifetime like so:

```ruby
SignedGlobalID.expires_in = 1.month
```

This way any generated SGID will use that relative expiry.

It's worth noting that _expiring SGIDs are not idempotent_ because they encode the current timestamp; repeated calls to `to_sgid` will produce different results. For example, in Rails

```ruby
Document.find(5).to_sgid.to_s == Document.find(5).to_sgid.to_s
# => false
```

You need to explicitly pass `expires_in: nil` to generate a permanent SGID that will not expire,

```ruby
# Passing a false value to either expiry option turns off expiration entirely.
never_expiring_sgid = Document.find(5).to_sgid(expires_in: nil)
# => #<SignedGlobalID:0x008fde45df8937 ...>

# Any time later...
GlobalID::Locator.locate_signed never_expiring_sgid
# => #<Document:0x007fae94bf6298 @id="5">
```

It's also possible to pass a specific expiry time

```ruby
explicit_expiring_sgid = SecretAgentMessage.find(5).to_sgid(expires_at: Time.now.advance(hours: 1))
# => #<SignedGlobalID:0x008fde45df8937 ...>

# 1 hour later...
GlobalID::Locator.locate_signed explicit_expiring_sgid.to_s
# => nil
```
Note that an explicit `:expires_at` takes precedence over a relative `:expires_in`.

**Purpose**

You can even bump the security up some more by explaining what purpose a Signed Global ID is for.
In this way evildoers can't reuse a sign-up form's SGID on the login page. For example.

```ruby
signup_person_sgid = Person.find(1).to_sgid(for: 'signup_form')
# => #<SignedGlobalID:0x007fea1984b520

GlobalID::Locator.locate_signed(signup_person_sgid.to_s, for: 'signup_form')
# => #<Person:0x007fae94bf6298 @id="1">
```

### Locating many Global IDs

When needing to locate many Global IDs use `GlobalID::Locator.locate_many` or `GlobalID::Locator.locate_many_signed` for Signed Global IDs to allow loading
Global IDs more efficiently.

For instance, the default locator passes every `model_id` per `model_name` thus
using `model_name.where(id: model_ids)` versus `GlobalID::Locator.locate`'s `model_name.find(id)`.

In the case of looking up Global IDs from a database, it's only necessary to query
once per `model_name` as shown here:

```ruby
gids = users.concat(people).sort_by(&:id).map(&:to_global_id)
# => [#<GlobalID:0x00007ffd6a8411a0 @uri=#<URI::GID gid://app/User/1>>,
#<GlobalID:0x00007ffd675d32b8 @uri=#<URI::GID gid://app/Student/1>>,
#<GlobalID:0x00007ffd6a840b10 @uri=#<URI::GID gid://app/User/2>>,
#<GlobalID:0x00007ffd675d2c28 @uri=#<URI::GID gid://app/Student/2>>,
#<GlobalID:0x00007ffd6a840480 @uri=#<URI::GID gid://app/User/3>>,
#<GlobalID:0x00007ffd675d2598 @uri=#<URI::GID gid://app/Student/3>>]

GlobalID::Locator.locate_many gids
# SELECT "users".* FROM "users" WHERE "users"."id" IN ($1, $2, $3)  [["id", 1], ["id", 2], ["id", 3]]
# SELECT "students".* FROM "students" WHERE "students"."id" IN ($1, $2, $3)  [["id", 1], ["id", 2], ["id", 3]]
# => [#<User id: 1>, #<Student id: 1>, #<User id: 2>, #<Student id: 2>, #<User id: 3>, #<Student id: 3>]
```

Note the order is maintained in the returned results.

### Custom App Locator

A custom locator can be set for an app by calling `GlobalID::Locator.use` and providing an app locator to use for that app.
A custom app locator is useful when different apps collaborate and reference each others' Global IDs.
When finding a Global ID's model, the locator to use is based on the app name provided in the Global ID url.

A custom locator can either be a block or a class.

Using a block:

```ruby
GlobalID::Locator.use :foo do |gid|
  FooRemote.const_get(gid.model_name).find(gid.model_id)
end
```

Using a class:

```ruby
GlobalID::Locator.use :bar, BarLocator.new
class BarLocator
  def locate(gid)
    @search_client.search name: gid.model_name, id: gid.model_id
  end
end
```

After defining locators as above, URIs like "gid://foo/Person/1" and "gid://bar/Person/1" will now use the foo block locator and `BarLocator` respectively.
Other apps will still keep using the default locator.

### Custom Class Loader strategy

By default the class loader just try to constantize the name:

```ruby
GlobalID.class_loader_strategy = -> (model_name) { model_name.constantize }
```

To define a custom class loader, you can assign the `class_loader_strategy`:

```ruby
GlobalID.class_loader_strategy = lambda (model_name) do
  nested_model = model_name.split('::').last.to_sym
  if Object.constants.include?(nested_model)
    Kernel.const_get(nested_model)
  else
    model_name.constantize
  end
end
```

The sample class loader above will check nested model name first:

```ruby
GlobalID.parse('gid://bar/Foo::Bar::Person/5').model_class # => Person
GlobalID.parse('gid://bar/Bar::Person/5').model_class # => Person
GlobalID.parse('gid://bar/Person/5').model_class # => Person
```

## Contributing to GlobalID

GlobalID is work of many contributors. You're encouraged to submit pull requests, propose
features and discuss issues.

See [CONTRIBUTING](CONTRIBUTING.md).

## License
GlobalID is released under the [MIT License](http://www.opensource.org/licenses/MIT).
