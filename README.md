# Simple Params

A simple class to handle parameter validation, for use in APIs or Service Objects.  Simply pass in your JSON hash, and get a simple, validateable, accessible ActiveModel-like object.

This class provides the following benefits for handling params:
  * Access via array-like (params[:person][:name]), or struct-like (params.person.name) syntax
  * Ability to validate with any ActiveModel validation
  * ActiveModel-like errors, including nested error objects for nested params
  * Parameter type-coercion (e.g. transform "1" into the Integer 1)

## Installation

Add this line to your application's Gemfile:

    gem 'simple_params', '~> 0.0.1pre'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_params

## Defining your Params class

All you need to do is create a class to specify accepted parameters and validations

```ruby
class MyParams < SimpleParams::Params
  param :name
  param :age, type: Integer
  param :date_of_birth, type: Date, optional: true
  param :hair_color, default: "brown", validations: { inclusion: { in: ["brown", "red", "blonde", "white"] }}

  nested_hash :address do
    param :street
    param :city
    param :zip_code, validations: { length: { in: 5..9 } }
    param :state, optional: true
    param :country, default: "USA"
  end

  # You can include whatever custom methods you need as well
  def full_address
    [address.street, address.city, address.state, address.zip_code].join(" ")
  end
end
```
We can now treat these params in very ActiveModel-like ways.  For example:

```ruby
params = MyParams.new(
  {
    name: "Bob Barker",
    age: "91",
    date_of_birth: "December 12th, 1923",
    hair_color: "white",
    address: {
      street: "7800 Beverly Blvd",
      city: "Los Angeles",
      state: "California",
      zip_code: "90036"
    }
  }
)

params.valid? #=> true
params.name #=> "Bob Barker"
params.full_address #=> "7800 Beverly Blvd Los Angeles California 90036"
```

## Validation & Errors

Errors are also treated in a very ActiveModel-like way, making it simple to validate even complexly nested inputs.

```ruby
params = MyParams.new(
  {
    name: "",
    age: "91",
    address: {
      city: "Los Angeles",
      state: "California",
      zip_code: "90036"
    }
  }
)

params.valid? #=> false
params.errors[:name] #=> ["can't be blank"] 
params.errors[:address][:street] #=> ["can't be blank"] 
params.address.errors[:street] #=> ["can't be blank"] 

params.errors.as_json #=> {:name=>["can't be blank"], :address=>{:street=>["can't be blank"]}} 
params.address.errors.as_json #=> {:street=>["can't be blank"]}  
```

## Defaults

It is easy to set simple or complex defaults, with either a static value or a Proc

```ruby
class DefaultParams < SimpleParams::Params
  param :name, default: "Doc Brown"
  param :first_initial, default: lambda { |params, attribute| params.name[0] }

  nested_hash :car do
    param :make, default: "DeLorean"
    param :license_plate, default: lambda { |params, attribute| params.make[0..2].upcase + "-1234" }
  end
end

params = DefaultParams.new

params.name #=> "Doc Brown"
params.first_initial #=> "D"
params.car.make #=> "DeLorean"
params.car.license_plate #=> "DEL-1234"
```

# Coercion

SimpleParams provides support for converting incoming params from one type to another.  This is extremely helpful for integers, dates, floats, and booleans, which will often come in as strings but should not be treated as such.

By default, params are assumed to be strings, so there is no need to specify String as a type.

```ruby
class CoercionParams < SimpleParams::Params
  param :name
  param :age, type: Integer
  param :date_of_birth, type: Date
  param :pocket_change, type: BigDecimal
end

params = CoercionParams.new(name: "Bob", age: "21", date_of_birth: "June 1st, 1980", pocket_change: "2.35")

params.name #=> "Bob"
params.age #=> 21
params.date_of_birth #=> #<Date: 1980-06-01>
params.pocket_change #=> #<BigDecimal:89ed240,'0.235E1',18(18)> 
```

SimpleParams also provide helper methods for implicitly specifying the type, if you prefer that syntax.  Here is the same class as above, but redefined with these helper methods.

```ruby
class CoercionParams < SimpleParams::Params
  param :name
  integer_param :age
  date_param :date_of_birth
  decimal_param :pocket_change
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request