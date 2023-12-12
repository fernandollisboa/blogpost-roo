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

      it 'creates the same number of bulls' do
        expect{ import_bulls }.to change{ Bull.count }.by(5)
      end
    end
  end
end
