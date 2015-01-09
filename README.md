# Global ID - Reference models by URI [![Build Status](https://secure.travis-ci.org/rails/globalid.png)](https://travis-ci.org/rails/globalid)

A Global ID is a URI that uniquely identifies a model instance:

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
>> person_gid = Person.find(1).to_global_id
=> #<GlobalID ...

>> person_gid.uri
=> #<URI ...

>> person_gid.to_s
=> "gid://app/Person/1"

>> GlobalID::Locator.locate person_gid
=> #<Person:0x007fae94bf6298 @id="1">
```

### Signed Global IDs

For added security GlobalIDs can also be signed to ensure that the data hasn't been tampered with.

```ruby
>> person_gid = Person.find(1).to_signed_global_id
=> #<SignedGlobalID:0x007fea1944b410

>> person_sgid = Person.find(1).to_sgid
=> #<SignedGlobalID:0x007fea1944b410

>> person_sgid.to_s
=> "BAhJIh5naWQ6Ly9pZGluYWlkaS9Vc2VyLzM5NTk5BjoGRVQ=--81d7358dd5ee2ca33189bb404592df5e8d11420e"

>> GlobalID::Locator.locate_signed person_sgid
=> #<Person:0x007fae94bf6298 @id="1">

```
You can even bump the security up some more by explaining what purpose a Signed Global ID is for. 
In this way evildoers can't reuse a sign-up form's SGID on the login page. For example.

```ruby
>> signup_person_sgid = Person.find(1).to_sgid(for: 'signup_form')
=> #<SignedGlobalID:0x007fea1984b520

>> GlobalID::Locator.locate_signed(signup_person_sgid, for: 'signup_form')
=> #<Person:0x007fae94bf6298 @id="1">
```

You can also have SGIDs that expire some time in the future. This is useful if there's a resource, 
people shouldn't have indefinite access to, like a share link.

```ruby
>> expiring_sgid = Document.find(5).to_sgid(expires_in: 2.hours, for: 'sharing')
=> #<SignedGlobalID:0x008fde45df8937

# Within 2 hours...
>> GlobalID::Locator.locate_signed(expiring_sgid, for: 'sharing')
=> #<Document:0x007fae94bf6298 @id="5">

# More than 2 hours later...
>> GlobalID::Locator.locate_signed(expiring_sgid, for: 'sharing')
=> nil

>> explicit_expiring_sgid = SecretAgentMessage.find(5).to_sgid(expires_at: Date.tomorrow.midnight)
=> #<SignedGlobalID:0x008fde45df8937

# After midnight...
>> GlobalID::Locator.locate_signed explicit_expiring_sgid
=> nil
```

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

## License

GlobalID is released under the MIT license.
