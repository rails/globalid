# Global ID - Reference models by URI [![Build Status](https://secure.travis-ci.org/rails/globalid.png)](https://travis-ci.org/rails/globalid)

A Global ID is a URI that uniquely identifies a model instance:

  gid://YourApp/Some::Model/id

This is helpful when you need a single identifier to reference different
classes of objects.

One example is job scheduling. We need to reference a model object rather than
serialize the object itself, so we pass a Global ID that can be used to locate
the model when it's time to perform the job. The job scheduler needn't know
the details of model naming and IDs, just that it has a global identifier that
references a model.

Another example is a drop-down list of options with Users and Groups. Normally
we'd need to come up with our own ad hoc scheme to reference them. With Global
IDs, we have a universal identifier that works for objects of both classes.


## Usage

Mix `GlobalID::Identification` in to any model with a #find(id) class method.
Support is automatically included in Active Record.

```ruby
>> person_gid = Person.find(1).to_global_id
=> #<GlobalID ...

>> person_gid.uri
=> #<URI ...

>> person_gid.to_s
=> "gid://app/Person/1"

>> GlobalID::Locator.locate person_gid
=> #<Person:0x007fae94bf6298 @id="1">
```

### Signed ID

To have secure forms, we advise to pass signed GID on the client side:

```ruby
>> person_gid = Person.find(1).to_signed_global_id
=> #<SignedGlobalID:0x007fea1944b410

# short alias
>> person_sgid = Person.find(1).to_sgid
=> #<SignedGlobalID:0x007fea1944b410

>> person_sgid.to_s
=> "BAhJIh5naWQ6Ly9pZGluYWlkaS9Vc2VyLzM5NTk5BjoGRVQ=--81d7358dd5ee2ca33189bb404592df5e8d11420e"

>> GlobalID::Locator.locate_signed person_sgid
=> #<Person:0x007fae94bf6298 @id="1">

# `for: 'purpose'` argument to secure the usage of the sgid. Ensures a sgid generated for one purpose can't be maliciously reused someplace else.
>> signup_person_sgid = Person.find(1).to_sgid(for: 'signup_form')
=> #<SignedGlobalID:0x007fea1984b520

>> GlobalID::Locator.locate_signed signup_person_sgid
=> #<Person:0x007fae94bf6298 @id="1">
```

### Custom locator

Useful when different apps collaborate and reference each others' Global IDs.
The locator can be either a block or a class.

`GlobalID::Locator.locate` finds an app based on the app in the `gid://` url. So a use call binds a locator to a specific app that the locator can find.

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

Here is Locator behaviour after declaring `:bar`:

```ruby
>> GlobalID::Locator.locate "gid://bar/User/39599"
=> your_model_found_with @search_client
```

## License

GlobalID is released under the MIT license.
