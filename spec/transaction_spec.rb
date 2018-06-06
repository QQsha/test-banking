require_relative 'spec_helper.rb'


describe 'Transaction' do

  date = '31.05.18'
  time = '18:42'
  description = 'Comision_deservire lunara/anuala card'
  amount = '-3,97'
  transaction = Transaction.new(date, time, description, amount)

  context 'when creating an instance' do
    it 'should return object class Transaction' do

      expect(transaction).to be_an_instance_of Transaction
    end
  end
end

describe 'Banking' do

  site = "https://da.victoriabank.md/frontend/auth/userlogin?execution=e2s1&locale=en"
  page = Banking.new(site)
  #page.login i stucked on this moment, when you need to enter captcha with rspec

  it { expect(page).to be_an_instance_of Banking}
end
