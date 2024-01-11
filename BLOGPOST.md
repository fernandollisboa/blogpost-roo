Have you ever wondered about the complexity of importing data from Excel files (`.xlsx`) into a Rails project? Considering that `.xlsx` files aren't plain-text like CSV, but rather a compilation of binary data, one might assume it to be a difficult task, right?

Surprisingly, no! Fortunately, there are brilliant minds in the community who generously share their solutions with us, and the maintainers of [Roo](https://github.com/roo-rb/roo) ) are among those people. In this blog post, we will explore into the process of setting up the Roo gem and explore various methods for efficiently importing data from rows within a ` .xlsx` file:

## Creating our spreadsheet and models

Imagine this scenario: you're a large-scale farm owner with an impressive collection of _mighty bulls_.You have information about these bulls saved in an Excel spreadsheet. Each bull is characterized by unique information such as a registration code, name, date of birth, and the total number of offspring. The data is organized in rows as follows:

| Registration Code | Name            | Born On    | Offspring Total |
| ----------------- | --------------- | ---------- | --------------- |
| 003               | Freddie The Big | 05/05/2015 | 20              |
| 002               | Arnold II       | 04/04/2014 | 10              |
| 001               | March           | 03/03/2013 | 5               |
| 000               | Zero            | 02/02/2012 | 0               |

As your collection of bulls grows, the idea of creating a web app to better track this information comes to mind. You'd like to store this data digitally to keep up with everything. The brilliant solution is to represent them as Ruby models. Let's start by creating our basic bull model and migration.

```rb
# migration
class CreateBulls < ActiveRecord::Migration[7.1]
  def change
    create_table :bulls do |t|
      t.string :registration_code
      t.string :name
      t.date :born_on
      t.integer :offspring_count

      t.timestamps
    end
  end
end

# model
class Bull < ApplicationRecord
  validates :name, :born_on, :offspring_count, presence: true
end
```

Now that you've got your model, database setup, and Excel spreadsheet, the next step is integrating the information flow from the spreadsheet to the Ruby models. This can be accomplished using various gems, and one such gem we'll explore is Roo.

## Roo Setup

Setting up Roo is incredibly straightforward! You can install it as a gem:

```sh
  $ gem install roo
```

Alternatively, add it to your Gemfile:

```rb
  gem "roo", "~> 2.10.0"
```

If you'd like more information on setup, you can find it in the official [README](https://github.com/roo-rb/roo#readme)

This gem enables you to import data from various spreadsheet types such as CSV, LibreOffice, OpenOffice, etc. However, in this concise tutorial, we'll focus on the Excel format. Keep in mind that some of these importation steps apply to these other formats, so don't hesitate to give them a try!

## Importing our data

To kick things off, let's initialize our spreadsheet model by providing its relative path and using `Roo::Excelx.new`. This will create an object representing our spreadsheet:

```rb
  spreadsheet = Roo::Excelx.new("./bulls.xlsx")
```

Now, let's explore some basic information about the spreadsheet using the `.info` method:

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

`Roo` provides multiple ways to interact with our imported data, and the best method depends on your business logic and data format. We'll present some options, but check out the [official docs](https://www.rubydoc.info/gems/roo) to find what fits your needs.

It's possible to access some important information about our spreadsheetd, some of this information has already been given to us with the `.info` method, but it can be useful to access these values directly, e.g:

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

You can iterate through each row as an array using the `.each` method:

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

This allow us to use the entire array to build our Bull objects. It's just a matter of knowing which column represents which data. It's crucial to note that even though you might know the column number/letter in the Excel file, the array exists as a Ruby object, so it follows Ruby logic, and the index starts at 0, so be careful!

If we are aware where the information is, we can also access it directly using `.cell(row, column)`. This method uses the Excel's numbering for row and columns, starting at 1. It can also be accessed using letters, but only the column value can be used a such. In this case, there's also a shorthand, as you'll se below, but we do not recommend this usage due to easy incosistancy using Excel's cell naming.

```rb
# Using only numbers
desired_row = 2
desired_column = 3

spreadsheet.cell(desired_row, desired_column_letter)
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

Alternatively, you may prefer to import it as a hash. We can achieve this by passing an options hash to specify the headers, allowing us to access the information using a key.

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

Another option is to use the `.parse` method to return an array of hashes, with each key/value pair representing a row. You can pass header values as strings or regex:

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

We can also stream each row using `.each_row_streaming`, which yields an array of [Excelx::Cell](https://www.rubydoc.info/gems/roo/Roo/Excelx/Cell/Base) per row, providing access to a number of uselful [helpers](https://www.rubydoc.info/gems/roo/Roo/Excelx/Cell).

By default, this method excludes blank cells from the array. You can include them (imported as nil) by using the option `pad_cells: true`. Additionally, you can offset the initial row (like the header/first row) by using the option `offset: X`.

Lastly, you can define the number of yields/passed rows with `max_rows: X` (it always increments by 1, e.g: X = 3 -&gt; max_rows: 4)

```rb

spreadsheet.each_row_streaming(offset: 1, max_rows: 2) do |row|
  puts row.inspect
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

Now that we've explored multiple ways to import our data, it's time to create our beloved bulls!

We can use any method to create them; in this example, we'll utilize the `.parse` method:

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

Now, let's check that our Bulls have been correctly created in our Rails console:

```rb
irb(main):001> Bull.all
=> [
  #<Bull:0x00007f16232494c0 id: 1, name: "Freddie The Biggie", born_on: Fri, 15 May 2015, offspring_count: 20, registration_code: "003", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>,
 #<Bull:0x00007f1623249380 id: 2, name: "Arnold II", born_on: Mon, 14 Apr 2014, offspring_count: 10, registration_code: "002", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>,
 #<Bull:0x00007f1623249240 id: 3, name: "March", born_on: Wed, 13 Mar 2013, offspring_count: 5, registration_code: "001", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>,
 #<Bull:0x00007f1623249100 id: 4, name: "Zero", born_on: Sun, 12 Feb 2012, offspring_count: 0, registration_code: "000", created_at: --- UTC +00:00, updated_at: --- UTC +00:00>
]
```

There it is! Now we can use these information to closely keep up with our handsome bulls. It's as simples and direct as it gets. In the real world, we would need to treat the data, look for inconsistencies and so on, but the core idea here is to realize that Excel files can be easily imported, and it really is that simple!

## Tests, Tests, Tests

So... how do we test it?

Well, we don't.

Really, we don't want to test the gem _per se_ - this is a job for the maintaners of the Roo gem. We will test if _our_ importation is working as intended, if the values are in the desired format, if we are correctly accessing the row and column we want.

A good practice would be to create service objects with the importation and test it. But, just like all things in life, it also _depends_. See what's the best fit for your project!

As an example, we've implemented some basic tests to verify if our importation is indeed creating bulls with the provided information and if it's creating all the bulls.

Primarily, we can use the helper [_fixture_file_upload_](https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html) to easily access example files, making it convenient to implement specific behavior. These files will be available at `spec/fixtures/files/` and we are using [rspec-rails](https://github.com/rspec/rspec-rails). Still, see what fits best for your app!

```rb
# spec/services/bulls/import_spec.rb
require 'rails_helper'

describe Bulls::Import, type: :service do
  describe '#call' do
    subject(:import_bulls) { described_class.new }

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
        expect{ import_bulls.call(file_path) }.to change{ Bull.count }.by(1)
      end

      it 'creates the bull with the provided information' do
        import_bulls.call(file_path)

        expect(Bull.last).to have_attributes(expected_attributes)
      end
    end

    context 'when there are multiple bulls in the spreadsheet' do
      let(:file_path) { fixture_file_upload('five_bulls_on_excel.xlsx') }

      it 'creates the correct number of bulls' do
	   expect{ import_bulls.call(file_path) }.to change{ Bull.count }.by(5)
      end
    end
  end
end
```

## Inconsistencies on data types (the _.cell_ and _.formatted_value_ paradox)

Now, this is some crucial information. If you haven't noticed yet, some magic has been happening since the start of this blog post. The format of the imported data is correct and precisely what we expected. But how does this happen? Well, it occurs because there is a type and format value assigned to each and every [Excelx::Cell](https://www.rubydoc.info/gems/roo/Roo/Excelx/Cell/Base) we've been using.

We can closely examine its type:

```rb
# We can discover the cell data type this way
spreadsheet.celltype(2, 3)
# => :date
```

This can return us on of these types:

- :float
- :string
- :date
- :percentage
- :formula
- :time
- :datetime

It's also possible to check the format of the data type in cases where we want to know de date format:

```rb
spreadsheet.excelx_format(2, 3)
=> "dd/mm/yyyy"
```

There we have it! The cell object has a _type_ and _format_. That's how Roo has been doing its magic. This type is defined by the file itself. It represents the data type/format defined by the user, be it a date, a number, or a string. So, when the data is displayed (as seen in the importations we did earlier), it already shows us the value in the expected type.

### External References and Usage of .formatted_value

In the real world, not all information and spreadsheets are created equally, or by the same person, people, even software, leading to potential inconsistencies and unexpected data types. Within the realm of spreadsheets, it's quite common to find examples where types are not explicitly defined, especially when determined by Excel reference formulas. In such cases, the nature of these values may not be immediately apparent, adding a layer of complexity to data interpretation.

To handle situations where the types of values are not explicitly defined, we need a different approach.This is where the `.formatted_value` method comes into play, offering a solution for accessing the underlying data representation in its raw string format. Unlike traditional methods that automatically infer data types (like `.cell`), `.formatted_value` provides a means to access the raw, unprocessed content of a cell. Consider it a direct pathway to the data's string representation. Depending on your requirements, you may need to access these values without automated inference, either for specific treatment or due to uncertainty about the data type of each cell.

### Conclusion

In a nutshell, this blog post aims to simplify the process for Rails developers to integrate Excel data into their projects using the Roo gem. Our goal was to provide a friendly introduction to the gem, encouraging newcomers to explore its features. By offering new methods for data importation, we aim to facilitate integration across domains and data storage approaches. Importing data as a spreadsheet can serve as a straightforward storage solution, promoting accessibility and experimentation within the developer community.

You can find the source code
