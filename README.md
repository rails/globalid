# GlobalID -- reference models by URI

GlobalID is a way of identifying a model with a URI, which can then be used to look it up later,
without the caller having to know the class. This is helpful in many cases where you accept different
classes of objects, but want to do so through a universal reference.

One example is jobs. We don't want to pass in full model objects to a job queue because the marshaling
of this object might well not be safe (given that the model object can hold references to database 
connections or other assets). So instead we pass a GlobalID that can use used to look up the model when
its time to perform the job.

Another example is a drop-down list of options with Users and Groups. By referencing both models as
GlobalIDs, we can make a receiver that simply takes a GlobalID -- or in the case of data that's being
exposed to the world, a tamper-proof SignedGlobalID -- and we can easily deal with objects of both classes.


## Usage

You can mix in ActiveModel::GlobalIdentification into any model that supports being found with a #find(id)
method. This gem will automatically include that module into ActiveRecord::Base, so all records will
be able to use the following methods:

```ruby
person_gid = Person.find(5).global_id         # => <#GlobalID ...
person_gid.to_s 					          # => "Person-5"
ActiveModel::GlobalLocator.locate(person_gid) # => <#Person id:5 ...
```

## License

GlobalID is released under the MIT license.
