# A Quick Guide on How to Import your Excel files using Roo

Have you ever asked yourself how hard it is to import data from Excel files (.xlsx) into a Rails project? Well, taking into account that .xlsx is not plain-text (like csv) but actually a lot of binary, it should be really hard, right?

Actually, no! Thankfully, there are some very smart people out there who love to share their sollutions with us, and the maintainers of [Roo](https://github.com/roo-rb/roo) are one of those people. So today we're gonna learn how to setup and start importing our beloved data from rows in a .xlsx file:

## Creating our spreadsheet and models

Let's imagine this: you're a really big farm owner, who owns a lot of mighty bulls. You'd like to have them saves as ruby models to check how they are doing with the offspring count. You'd like to have rows with the following information:

| Registration Code | Name            | Born On    | Offspring Total |
| ----------------- | --------------- | ---------- | --------------- |
| 003               | Freddie The Big | 05/05/2015 | 20              |
| 002               | Arnold II       | 04/04/2014 | 10              |
| 001               | March           | 03/03/2013 | 5               |
| 000               | Zero            | 02/02/2012 | 0               |

Great! Let's save this file with the name bulls.xlsx and create our basic bulls model and migration:

_talvez isso aqui embaixo seja desnecessauro_

```rb
# migration
class CreateBulls < ActiveRecord::Migration[7.1]
  def change
    create_table :bulls do |t|
      t.string :name
      t.date :born_on
      t.integer :offspring_count
      t.string :registration_code

      t.timestamps
    end
  end
end

# model
class Bull < ApplicationRecord
  validates :name, :born_on, :offspring_count, presence: true
end
```

## Roo Setup

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

We can start with simply initilizaing you spreadsheet model sing its relative path and Roo::Excel.new:

```rb
  spreadsheet = Roo::Excelx.new("./bulls.xlsx")
```

Then we can iterate over our spreadsheet and get the rows as arrays

```rb
  spreadsheet.each do |row|
    puts row.inspect
  end
  # ["Registration Code", "Name", "Born On", "Offspring Count"]
  # ["003", "Freddie The Biggie", Tue, 05 May 2015, 20]
  # ["002", "Arnold II", Fri, 04 Apr 2014, 10]
  # ["001", "March", Sun, 03 Mar 2013, 5]
  # ["000", "Zero", Thu, 02 Feb 2012, 0]
```

Or maybe you'd like to import it as a hash?

```rb
  bull_attributes_headers = {
    registration_code: 'Registration Code',
    name: 'Name',
    born_on: 'Born On',
    offspring_count: 'Offspring Count'
  }

  # This will check for the correct headers values
  spreadsheet.each(bull_attributes_headers) do |row|
    puts row.inspect
  end
  # {:registration_code=>"Registration Code", :name=>"Name", :born_on=>"Born On", :offspring_count=>"Offspring Count"}
  # {:registration_code=>"003", :name=>"Freddie The Biggie", :born_on=>Tue, 05 May 2015, :offspring_count=>20 }
  # {:registration_code=>"002", :name=>"Arnold II", :born_on=>Fri, 04 Apr 2014, :offspring_count=>10}
  # {:registration_code=>"001", :name=>"March", :born_on=>Sun, 03 Mar 2013, :offspring_count=>5}
  # {:registration_code=>"000", :name=>"Zero", :born_on=>Thu, 02 Feb 2012, :offspring_count=>0}
```
