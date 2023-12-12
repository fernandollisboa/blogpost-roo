# A Quick Guide on How to Import your Excel files using Roo

Have you ever asked yourself how hard it is to import data from Excel files (.xlsx) into a Rails project? Well, taking into account that .xlsx is not plain-text (like csv) but actually a lot of binary, it should be really hard, right?

Actually, no! Thankfully, there are some very smart people out there who love to share their sollutions with us, and the maintainers of [Roo](https://github.com/roo-rb/roo) are one of those people. So today we're gonna learn how to setup the gem and explore different ways to import our beloved data from rows in a .xlsx file:

## Creating our spreadsheet and models

Let's picture this: you're a really big farm owner, who owns a lot of *mighty bulls*. You'd like to have them saved somewhere digitally to keep up with them, so you have the brilliant ideia to represent them as ruby models, see their personal information and the offspring count. You'd have rows with the following information:

| Registration Code | Name            | Born On    | Offspring Total |
| ----------------- | --------------- | ---------- | --------------- |
| 003               | Freddie The Big | 05/05/2015 | 20              |
| 002               | Arnold II       | 04/04/2014 | 10              |
| 001               | March           | 03/03/2013 | 5               |
| 000               | Zero            | 02/02/2012 | 0               |

Great! Let's save this file with the name bulls.xlsx and create our basic bulls model and migration!
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

If you'd like more information on setup, you can find  it in the official [README](https://github.com/roo-rb/roo#readme)

This gem allows you to impoprt data from different spreadsheet types, like CSV, LibreOffice, OpenOffice etc; but in this brief tutorial we'll only tackle the Excel format, some of these importation steps apply to these other formats, so do not be descouraged to try it out either way!  

## Importing our data

We can start by simply initializing you spreadsheet model using its relative path and Roo::Excelx.new, which will instantiate an object representing our spreadsheet:

```rb
  spreadsheet = Roo::Excelx.new("./bulls.xlsx")
```
We can check some basic information about the spreadsheet using:

```rb
  spreadsheet.info

  # => File: bulls.xlsx
  # Number of sheets: 1
  # Sheets: Página1
  # First row: 1
  # Last row: 5
  # First column: A 
  # Last column: D
```

*Roo* provide us with multiple ways to interact with our imported data, the best one is up to you, it can depend on your business logic, data format and so on, we'll present some ways, but check out the [official docs](https://www.rubydoc.info/gems/roo) to know what fits better for you

We can access some important information about our spreadsheet object, some of this information has already been given to us with the *.info* method, but it can be useful to access these values directly, e.g:
```rb
spreadsheet.first_row
# => 1

spreadsheet.last_row
# => 5

spreadsheet.first_column
# => 1

spreadsheet.last_column
# => 5

spreadsheet.first_column_as_letter
# => "A"

spreadsheet.last_column_as_letter
# => "D"
```
We can access each row as an array, iterating the spreadsheet with *.each*:
```rb
  # This will also access the headers if there are any!
  spreadsheet.each do |row|
    puts row.inspect
  end

  # ["Registration Code", "Name", "Born On", "Offspring Count"]
  # ["003", "Freddie The Biggie", Tue, 05 May 2015, 20]
  # ["002", "Arnold II", Fri, 04 Apr 2014, 10]
  # ["001", "March", Sun, 03 Mar 2013, 5]
  # ["000", "Zero", Thu, 02 Feb 2012, 0]
```
This allow us to use the whole array to build our Bull objects, it is only a matter of knowing which column represents which data, but is important to note that even though you might know what the column number/letter on the excel file is, the array exists as an ruby object, so it applies ruby logic, as such the index starts at 0, so be careful!

If we know where the information we want is, we can also access it directly using *.cell(row, column)*, this method uses the excel numeration for row and columns, as such it starts on 1, it can also be accessed using letters, but only the column value can be used a such, in this case there is also a shorthand as you'll se below, but we do not think its good practice to use it.

```rb
# Using only numbers
desired_row = 2
desired_column = 3

spreadsheet.cell(desired_row, desired_column)
# => Fri, 15 May 2015
```

```rb
# Using column as a letter
desired_column_letter = 'C'

spreadsheet.cell(desired_row, desired_column_letter)
# => Fri, 15 May 2015
```

```rb
# Shorthand (we do not recommend this usage)
spreadsheet.c2
# => Fri, 15 May 2015
```

Or maybe you'd like to import it as a hash? we can pass an options hash to specify the headers, this way we can access the information using a key, pretty cool, right?

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
Alternatively we can use the *.parse* method to return an *array* of hashes, each hash in the array representing an row. Just like with the above solution we can pass the header values, but in this way we can use *Strings* or *Regexp*, here the header is not returned!
```rb
spreadsheet.parse(
  registration_code: 'Registration Code',
  name: /Name/,
  born_on: 'Born On',
  offspring_count: 'Offspring Count'
)

# => [
#     {:registration_code=>"003", :name=>"Freddie The Biggie", :born_on=>Fri, 15 May 2015, :offspring_count=>20},
#     {:registration_code=>"002", :name=>"Arnold II", :born_on=>Mon, 14 Apr 2014, :offspring_count=>10},
#     {:registration_code=>"001", :name=>"March", :born_on=>Wed, 13 Mar 2013, :offspring_count=>5},
#     {:registration_code=>"000", :name=>"Zero", :born_on=>Sun, 12 Feb 2012, :offspring_count=>0}
#   ]
```

While using an Excel spreadsheet we can also stream each row using *.each_row_streaming*, which will yield an array of [Excelx::Cell](https://www.rubydoc.info/gems/roo/Roo/Excelx/Cell/Base) per row, which have access to a number of uselful [helpers](https://www.rubydoc.info/gems/roo/Roo/Excelx/Cell)

By default this method excludes blank cells from the array, you can include them (imported as nil) by using the option *pad_cells: true*, also, you can offset the initial row (like the header/first row) by using the option *offset: X*

Lastly , you can also define the number of *yields/passed rows* with *max_rows: X* (it always increments 1, e.g: X = 3 -> max_rows: 4)
```rb

spreadsheet.each_row_streaming(offset: 1, max_rows: 2) do |row|
  puts row.inpect
end

# => [
#     #<Roo::Excelx::Cell::String:0xb58 @cell_value="003", @coordinate=[2, 1], @value="003">, 

#     #<Roo::Excelx::Cell::String:0xb08 @cell_value="Freddie The Biggie", @coordinate=[2, 2], @value="Freddie The Biggie">,

#     #<Roo::Excelx::Cell::Date:0xac0 @cell_value="42139", @cell_type=[:numeric_or_formula, "dd/mm/yyyy"], @style=2, @coordinate=[2, 3], @value=Fri, 15 May 2015, @format="dd/mm/yyyy">,

#     #<Roo::Excelx::Cell::Number:0xab8 @cell_value="20", @cell_type=[:numeric_or_formula, "General"], @coordinate=[2, 4], @value=20, @format="General">
#   ]
# ...

```
### Creating our bulls objects
Now that we know multiple ways to import our data we can finally create our beloved bulls!

We can create them using any method, we'll use the parse one
```rb
  bull_attributes_headers = {
    registration_code: 'Registration Code',
    name: 'Name',
    born_on: 'Born On',
    offspring_count: 'Offspring Count'
  }

  spreadsheet.parse(bull_attributes_headers) do |row|
    Bull.create(
      registration_code: row[:registration_code],
      name: row[:name],
      born_on: row[:born_on],
      offspring_count: row[:offspring_count]
    )
  end
```
Now let's check that our Bulls have been correctly created in our rails console
```rb
irb(main):001> Bull.all
=> [
  #<Bull:0x00007f16232494c0 id: 1, name: "Freddie The Biggie", born_on: Fri, 15 May 2015, offspring_count: 20, registration_code: "003", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>,

 #<Bull:0x00007f1623249380 id: 2, name: "Arnold II", born_on: Mon, 14 Apr 2014, offspring_count: 10, registration_code: "002", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>,

 #<Bull:0x00007f1623249240 id: 3, name: "March", born_on: Wed, 13 Mar 2013, offspring_count: 5, registration_code: "001", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>,
 
 #<Bull:0x00007f1623249100 id: 4, name: "Zero", born_on: Sun, 12 Feb 2012, offspring_count: 0, registration_code: "000", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>
]
```
There it is! Now we can use these information to closely keep up with our handsome bulls! It's as simples and direct as it gets. In the real world we would need to treat the data, look for inconsistencies and so on, but the core ideia here is to realize that excel files can be easily imported, and it really is that simple!

## Tests, Tests, Tests
So.. how do we test it?

We don't.

Really, we don't want to test the gem per say, this is a job for the maintaners of the Roo gem, we will test if *our* importation is working as intended, if the values are on the desired format, if we are correctly accessing the row and column we want.

A good practice would be to create service objects with the importation and testing it (that's what we've done!) but just like all things on life, it also *depends*, see what's the best fit for your project!

As an example we created some basic testing to see if our importation really is creating the bulls with the provided information and if it is really creating all the bulls.

Mainly we used the helper [*fixture_file_upload*](https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html) to easily access example files to implement specific behaviour, these files we'll be available to be accessed at *spec/fixtures/files* and we are using [rspec-rails](https://github.com/rspec/rspec-rails), but see what fits best your app!
```rb
# spec/services/bulls/import_spec.rb
require 'rails_helper'

describe Bulls::Import, type: :service do
  describe '#call' do
    subject(:import_bulls) { described_class.new.call(file_path) }

    context 'when all information is valid' do
      let(:file_path) { fixture_file_upload('one_bull_with_valid_information.xlsx') }

      let(:expected_attributes) do
        {
          registration_code: '000',
          name: 'Zero',
          born_on: Date.parse('Sun, 12 Feb 2012'),
          offspring_count: 0
        }
      end

      it 'creates one bull' do
        expect{ import_bulls }.to change{ Bull.count }.by(1)
      end

      it 'creates the bull with the provided information' do
        import_bulls

        expect(Bull.last).to have_attributes(expected_attributes)
      end
    end

    context 'when there are multiple bulls in the spreadsheet' do
      let(:file_path) { fixture_file_upload('five_bulls_on_excel.xlsx') }

      it 'creates the correct number of bulls' do
        expect{ import_bulls }.to change{ Bull.count }.by(5)
      end
    end
  end
end
```

## Inconsistencies on data types (the *.cell* and *.formatted_value* paradox)
Now this is some important stuff, if you've haven't noticed yet, some magic has been happening since the start of this blogpost, the format of the imported data is correct and is exactly what we expected, but... how? Well, this happens because there is a *type* and *format* value assigned to each and every [Excelx::Cell](https://www.rubydoc.info/gems/roo/Roo/Excelx/Cell/Base) we've been using.

We can check this format closely:
```rb
# We can discover the cell data type this way
spreadsheet.celltype(2, 3)
# => :date
```
This can return us on of these types:
* :float 
* :string
* :date 
* :percentage 
* :formula 
* :time 
* :datetime

We can even see the format of the data type in cases where we want to know de date format:
```rb
spreadsheet.excelx_format(2, 3)
=> "dd/mm/yyyy"
```
There we have it, the cell object has a *type* and *format*, that's how Roo has been doing its magic, this type is defined by the file itself, its the data type/format defined by the user, be it a date, a number or a string, so when the data is to be displayed (as seen in the importations we did earlier) it already show us the value in the expected type.

But in the real world not all information and spreadsheets are created equally, or by the same person, or people, or even software, as such we can expect some inconsistencies and not expected data types, so we can also access those values in a different way, instead of using *cell* or the iterative ways we saw earlier we can also use *.formatted_value*, think of it as a direct access to what represent the data in string, depending on your needs you'll need to access this values without the magic and do it yourself, be it because you want to treat it in some way or because you can't know for sure what the data type of each cell is.

It is used the same way as the *.cell* method, so it is really simples to pick it up.