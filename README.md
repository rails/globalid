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
>> person_gid = Person.find(1).global_id
=> #<GlobalID ...

>> person_gid.uri
=> #<URI ...

>> person_gid.to_s
=> "gid://app/Person/1"

>> GlobalID::Locator.locate person_gid
=> #<Person:0x007fae94bf6298 @id="1">
```

## License

GlobalID is released under the MIT license.
