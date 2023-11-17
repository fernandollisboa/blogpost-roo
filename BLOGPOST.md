# A Quick Guide on How to Import Excel files in your Ruby on Rails project

Have you ever asked yourself how hard it is to import data from Excel files (.xlsx) into a Rails project? Well, taking into account that .xlsx is not plain-text (like csv) but actually a lot of binary, it should be really hard, right?

Actually, no! Thankfully, there are some very smart people out there who love to share their sollutions with us, and the maintainers of [Roo](https://github.com/roo-rb/roo) are one of those people. So today we're gonna learn how to setup and start importing our beloved data from rows in a .xlsx file:

## Creating our spreadsheet and models

Let's imagine this: you're a really big farm owner, who owns a lot of mighty bulls. You'd like to have them saves as ruby models to check how they are doing with the offspring count. You'd like to have rows with the following information:

| Name            | Born On    | Offspring Total | Registration Code |
| --------------- | ---------- | --------------- | ----------------- |
| Freddie The Big | 05/05/2015 | 20              | 003               |
| Arnold II       | 04/04/2014 | 10              | 002               |
| March           | 03/03/2013 | 5               | 001               |
| Zero            | 02/02/2012 | 0               | 000               |

Great! Let's save this file with the name bulls.xlsx and create our basic bulls model and migration:

talvez isso aqui embaixo seja desnecessauro

```rb
# migration
class CreateBulls < ActiveRecord::Migration[7.1]
  def change
    create_table :bulls do |t|
      t.string :name
      t.string :born_on
      t.string :offspring_count

      t.timestamps
    end
  end
end

# model
class Bull < ApplicationRecord
  validates :name, :born_on, :offspring_count, presence: true
end
```

## Gem Setup

Roo setup is dead simple! You can install it as a gem:

```bash
$ gem install roo
```

Or add it to your Gemfile

```rb
  gem "roo", "~> 2.10.0"
```

If you'd like more information on setup, you can find in the official [README](https://github.com/roo-rb/roo#readme)

## Importing our data
