module Bulls
  class Import
    def call(file_path)
      spreadsheet = Roo::Excelx.new(file_path)

      bull_attributes_headers = {
        registration_code: 'Registration Code',
        name: 'Name',
        born_on: 'Born On',
        offspring_count: 'Offspring Count'
      }

      spreadsheet.each(bull_attributes_headers) do |row|
        Bull.create(
          registration_code: row[:registration_code],
          name: row[:name],
          born_on: row[:born_on],
          offspring_count: row[:offspring_count]
        )
      end
    end
  end
end
