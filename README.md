# Resourcify [![Gem Version](https://badge.fury.io/rb/resourcify.png)](http://badge.fury.io/rb/resourcify)

Resourcify is a rails gem that helps to speed up development by giving you json api controllers that inherit all restful actions. It also makes your models easier to filter by adding a "filter_by" method. This gem behaves as an "acts_as" gem by using ActiveSupport Concerns.

#### Caveat
The resourcify gem currently depends on [Pundit](https://github.com/elabs/pundit)

## Installation

### Rails 4

Include the gem in your Gemfile:

```ruby
gem 'resourcify', '0.1.4'
```

## Usage

Applies to different parts of Rails:

* [Controllers](#controllers)
* [Models](#models)

### Controllers

Usage with controllers is very easy. Just add "resourcify" to your controller and your controller will inherit all the RESTful actions with json response.

```ruby
class PostsController < ApplicationController
  # Include the resourcify module
  resourcify
  
end
```
```ruby
class PostsController < ApplicationController
  # Include the resourcify module with preferred actions as an array
  # Valid actions are: :index, :create, :show, :update, :destroy
  resourcify actions: [:index, :show]
  
end
```

You can check the [base.rb file](https://github.com/stephenbaidu/resourcify/blob/master/lib/resourcify/controller/base.rb) to see the private methods that have been made available.

#### Strong Parameters

By default, your controller has a permitted_params method for rails strong parameters like this. "_RC" is the resource class or model class.

```ruby
# Only allow a trusted parameter "white list" through.
def permitted_params
  if self.respond_to? "#{controller_name.singularize}_params", true
    self.send("#{controller_name.singularize}_params")
  else
    param_key        = _RC.name.split('::').last.singularize.underscore.to_sym
    excluded_fields  = ["id", "created_at", "updated_at"]
    permitted_fields = (_RC.column_names - excluded_fields).map { |f| f.to_sym }
    params.fetch(param_key, {}).permit([]).tap do |wl|
      permitted_fields.each { |f| wl[f] = params[param_key][f] if params[param_key].key?(f) }
    end
  end
end
```
You can override this by defining a custom method called "permitted_params" (or "post_params" for PostsController) in your controller.

### Models

Assuming you have the following models (Post, User) in your application.

```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  
  belongs_to :user
end

class User < ActiveRecord::Base
  attr_accessible :first_name, last_name, age
end
```

Then you can add "resourcify" like this

```ruby
class Post < ActiveRecord::Base
  # Include the resourcify module
  resourcify
  
  attr_accessible :title
  
  belongs_to :user
end

class User < ActiveRecord::Base
  # Include the resourcify module
  resourcify
  
  attr_accessible :first_name, last_name, age
end
```

This allows you to filter your models like this
```ruby
# Post with title equal to 'My First Post'
Post.filter_by('title' => 'My First Post')

# Users with first_name like 'Jo'
User.filter_by('first_name.like' => 'Jo')

# The following parameters are allowed:
# [eq(=), ne(!=), like(LIKE), lt(<), gt(>), lte(<=), gte(>=), in(IN [items]), nin(NOT IN [items])]
User.filter_by('first_name.like' => 'Jo', 'last_name.eq' => 'Doe')
User.filter_by('age.gt' => 37)
User.filter_by('age.gte' => 21, 'age.lte' => 35)

# Users with age in [25, 26, 52, 62] 
User.filter_by('age.in' => '25,26,52,62')
```

Each model with  "resourcify" has a "policy_class" method which returns "ApiPolicy" that can be used by a generic api controller when using Pundit. This was added since the gem is currently tied with Pundit but will later be made optional.

## License

Resourcify is free software, and may be redistributed under the terms specified in the [MIT-LICENSE](MIT-LICENSE) file.