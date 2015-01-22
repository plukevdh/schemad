# Schemad

[![Gem Version](https://badge.fury.io/rb/schemad.svg)](http://badge.fury.io/rb/schemad)
[![Build Status](https://travis-ci.org/plukevdh/schemad.svg?branch=master)](https://travis-ci.org/plukevdh/schemad)

Schemad is a simple metagem to aid integrating legacy or third-party datasets into other projects. It's especially geared towards unifying multiple datasets into consistent data structures for ease of and consistency in use.

This gem has two main parts: Normalizers and Entities.

## Normalizers

Normalizers are the translators between different datasets. They take misshaped data and help mold it into a consistent form before turning them into objects for general use.

For example, let's say I want to pull commit data from [GitHub](https://github.com) and [BitBucket](https://bitbucket.org) and do something with the two datasets. Let's look at the API for both and the kind of data they return for a commit object.

### GitHub Commit API
> [Source](https://developer.github.com/v3/git/commits/)

```json
{
  "sha": "7638417db6d59f3c431d3e1f261cc637155684cd",
  "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/7638417db6d59f3c431d3e1f261cc637155684cd",
  "author": {
    "date": "2010-04-10T14:10:01-07:00",
    "name": "Scott Chacon",
    "email": "schacon@gmail.com"
  },
  "committer": {
    "date": "2010-04-10T14:10:01-07:00",
    "name": "Scott Chacon",
    "email": "schacon@gmail.com"
  },
  "message": "added readme, because im a good github citizen\n",
  "tree": {
    "url": "https://api.github.com/repos/octocat/Hello-World/git/trees/691272480426f78a0138979dd3ce63b77f706feb",
    "sha": "691272480426f78a0138979dd3ce63b77f706feb"
  },
  "parents": [
    {
      "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/1acc419d4d6a9ce985db7be48c6349a0475975b5",
      "sha": "1acc419d4d6a9ce985db7be48c6349a0475975b5"
    }
  ]
}
```

### BitBucket Commit API
> [Source](https://confluence.atlassian.com/display/BITBUCKET/commits+or+commit+Resource#commitsorcommitResource-GETanindividualcommit)

```json
{
    hash: "61d9e64348f9da407e62f64726337fd3bb24b466",
    links: {
        self: {
            href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/commit/61d9e64348f9da407e62f64726337fd3bb24b466"
        },
        comments: {
            href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/commit/61d9e64348f9da407e62f64726337fd3bb24b466/comments"
        },
        patch: {
            href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/patch/61d9e64348f9da407e62f64726337fd3bb24b466"
        },
        html: {
            href: "https://api.bitbucket.org/atlassian/atlassian-rest/commits/61d9e64348f9da407e62f64726337fd3bb24b466"
        },
        diff: {
            href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/diff/61d9e64348f9da407e62f64726337fd3bb24b466"
        },
        approve: {
            href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/commit/61d9e64348f9da407e62f64726337fd3bb24b466/approve"
        }
    },
    repository: {
        links: {
            self: {
                href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest"
            },
            avatar: {
                href: "https://d3oaxc4q5k2d6q.cloudfront.net/m/bf1e763db20f/img/language-avatars/java_16.png"
            }
        },
        full_name: "atlassian/atlassian-rest",
        name: "atlassian-rest"
    },
    author: {
        raw: "Joseph Walton <jwalton@atlassian.com>",
        user: {
            username: "jwalton",
            display_name: "Joseph Walton",
            links: {
                self: {
                    href: "https://api.bitbucket.org/2.0/users/jwalton"
                },
                avatar: {
                    href: "https://secure.gravatar.com/avatar/8e6e91101e3ed8a332dbebfdf59a3cef?d=https%3A%2F%2Fd3oaxc4q5k2d6q.cloudfront.net%2Fm%2Fbf1e763db20f%2Fimg%2Fdefault_avatar%2F32%2Fuser_blue.png&s=32"
                }
            }
        }
    },
    participants: [{
        role: "PARTICIPANT",
        user: {
            username: "evzijst",
            display_name: "Erik van Zijst",
            links: {
                self: {
                    href: "https://api.bitbucket.org/2.0/users/evzijst"
                },
                avatar: {
                    href: "https://secure.gravatar.com/avatar/f6bcbb4e3f665e74455bd8c0b4b3afba?d=https%3A%2F%2Fd3oaxc4q5k2d6q.cloudfront.net%2Fm%2Fbf1e763db20f%2Fimg%2Fdefault_avatar%2F32%2Fuser_blue.png&s=32"
                }
            }
        },
        approved: false
    }],
    parents: [{
        hash: "59721f593b020123a75424285845325126f56e2e",
        links: {
            self: {
                href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/commit/59721f593b020123a75424285845325126f56e2e"
            }
        }
    }, {
        hash: "56c49d8b2ae3a094fa7ba5a1251d6dd2c7c66993",
        links: {
            self: {
                href: "https://api.bitbucket.org/2.0/repositories/atlassian/atlassian-rest/commit/56c49d8b2ae3a094fa7ba5a1251d6dd2c7c66993"
            }
        }
    }],
    date: "2013-10-21T07:21:51+00:00",
    message: "Merge remote-tracking branch 'origin/rest-2.8.x' "
}
```

Obviously, mining the two datasets for a bunch of commits will require a lot of parsing to unify the two data structures presented here.

In step the Normalizers. For this example ee'd create two separate normalizers for these datasets, one for GH, one for BB:

```ruby
class GitHubNormalizer < Schemad::Normalizer
  normalize :id, key: :sha
  normalize :committer, key: "committer/name"
  normalize :created_date, key: "committer/date"
  normalize :comment, key: :message
  
  include_fields :url
end
```

We could obviously also include additional data if we wanted. Notice you can use either symbols or strings as keys. If you want to do a deep traversal (more than one level), you will need to use strings with a "/" delimited path. 

Also notice that if you want fields to be included 'as is', using the same key as the dataset provided, you can use the `include_fields` method. Normalizers _only return_ data that you specify.

Now for BitBucket:

```ruby
class BitBucketNormalizer < Schemad::Normalizer
  normalize :id, key: :hash
  normalize :url, key: "links/self/href"
  normalize :committer, key: "author/user/display_name"
  normalize :created_date, key: :date
  normalize :comment, key: :message
end
```

Sweet. So now when we get the json from the API, all we need to do with these classes is:

```ruby
raw_json = some_http_get("https://api.github.com/path/to/my/commit")
github_data = JSON.parse(raw_json)

parsed = GitHubNormalizer.new.normalize(github_data)
```

And we should then have a plain hash much like the following:

```ruby
{
  id: "7638417db6d59f3c431d3e1f261cc637155684cd",
  url: "https://api.github.com/repos/octocat/Hello-World/git/commits/7638417db6d59f3c431d3e1f261cc637155684cd",
  committer: "Scott Chacon",
  created_date: "2010-04-10T14:10:01-07:00",
  comment: "added readme, because im a good github citizen\n"
}
```

Our BitBucket normalizer would work the same way, we'd just use it to run through data harvested by our BitBucket requests.

Two things of mention: First, the normalizers can also be passed a block to perform additional data manipulation. For example, assume we wanted to harvest an email field. GitHub provides this to us directly to use:

```ruby
class GitHubNormalizer < Schemad::Normalizer
  # ... other normalizers
  normalize :email, key: "committer/email"
end
```

However, BitBucket does not directly. It's wrapped within the "raw" field in the author hash. So we can provide additional modifiers to get this:

```ruby
class BitBucketNormalizer < Schemad::Normalizer
  # ... other normalizers
  normalize :email, key: "author/raw" do |value|
    value.match(/\A[\w|\s]+<(.+)>\z/).captures.first
  end
end
```

Now the normalizer will use the raw field and pick out the email using a regex matcher. Now you might be tempted to use the normalizer blocks to manipulate the fields into ruby types, as the normalizers do not attempt to parse the data types. You'll notice in the above examples that date strings are left as strings through the normalization. This brings us to our second thing to note: Normalizers _only parse data into consistent structures_. They are not responsible for type casting. This is intentional and brings us to the role of the Entity.

## Entities

Entities provide consistent [value objects](http://martinfowler.com/bliki/ValueObject.html) that allow for easily transporting the data to functionality that uses the data. Entities are very limited in functionality and are mainly meant to provide a more ruby-ish means of accessing the data. We _could_ pass around the normalized hashes, but typically, we rubyists like having method access to our data:

```ruby
commit.comment        # "added readme, because im a good github citizen\n"
commit.id             # "7638417db6d59f3c431d3e1f261cc637155684cd"
comment.created_date  # A time object!
```

So this is what Entities provide.

```ruby
class Commit < Schemad::Entity
  attribute :id
  attribute :committer
  attribute :comment
  attribute :created_date, type: :date_time
  attribute :email
  attribute :url
end
```

Note that the default attribute type (if not provided) is a string (`:string`). Currently supported types are

- :string
- :time, :date, :date_time (all the same in our case)
- :integer
- :boolean

To get these types, simply `require 'schemad/default_types'`. They are not required by default to ensure that my Schemad's type handling is what you want explicity.

New types are easy to create, more on this in a moment.

To instantiate these new class, we use the `from_data` method to ensure parsing with the output from the normalizer step above:

```ruby
raw_json = some_http_get("https://api.github.com/path/to/my/commit")
github_data = JSON.parse(raw_json)

parsed = GitHubNormalizer.new.normalize(github_data)

commit = Commit.from_data(parsed)

commit.comment        # "added readme, because im a good github citizen\n"
commit.id             # "7638417db6d59f3c431d3e1f261cc637155684cd"
comment.created_date  # A time object!
```

You don't have to use the normalizers to use the `from_data` method. It can be any consistently formatted hash. The keys **must** be accessible by symbol however (use a hash with all symbols as keys or an ActiveSupport/Hashie/other [HashWithIndifferentAccess](http://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html) implementation).

In fact, both normalizer and entity can be used independent of one another if one or the other isn't required for your use. Just include the library you want:

```ruby
require 'schemad/type_handler'
require 'schemad/normalizer'
require 'schemad/entity'

# or to get all...
require 'schemad'
```

## Type Handlers

On a side note, we have a number of very simple type handlers, you can see them all in the various type definitions [type_handler](https://github.com/plukevdh/schemad/tree/master/lib/schemad/types).

It is _also_ possible to use these however you want in your own classes, but there are far more complete and complex type handlers elsewhere. If you find these types unsatisfactory or wish to use additional types, you can easily define your own.

```ruby
require 'schemad/type_handler'
require 'schemad/abstract_handler'

class YouMomHandler < Schemad::AbstractHandler
  handle :your_mom

  def parse(value)
    "Your Mom"
  end
end

# register this handler
Schemad::TypeHandler.register YourMomHandler

# alternatively...
YourMomHandler.register_with Schemad::TypeHandler
```

Now when you want to have your entity turn anything into your mother, simply add the type `:your_mom` to the attribute definition.

```ruby
class Commit < Schemad::Entity
  # ...
  attribute :comment, type: :your_mom
end

commit = Commit.from_data(parsed)

commit.comment        # "Your Mom"
```

## Notes

[Hashie](https://github.com/intridea/hashie) is probably a better idea than this gem. But I couldn't find a decent way to combine the [DeepFetch](https://github.com/intridea/hashie#deepfetch) functionality with the [Dash](https://github.com/intridea/hashie#dash)/[Trash](https://github.com/intridea/hashie#trash) functionality. This is also likely much ligher weight and therefore about half as meta.

Be warned, this is a lot of crazy metacode and it's _mostly_ recommended you don't use this for real. Mostly. But it is awesome.

## Installation

Add this line to your application's Gemfile:

    gem 'schemad'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install schemad

## Contributing

1. Fork it ( https://github.com/[my-github-username]/schemad/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
