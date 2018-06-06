require 'watir'
require 'open-uri'
require 'json'



class Banking
  attr_reader :arg

  def initialize(arg)
    website = arg
    setup(website)
  end

  def setup(website)
    @browser = Watir::Browser.new :chrome
    @browser.goto(website)
  end

  def login
    username = 'qqsha'
    password = 'Victoria562433' # This is my old bank account, so i dont care about security now.
    puts 'Enter the Captcha you See: '
    captcha = gets.chomp
    proceed(username, password, captcha)
  end

  def proceed(username, password, captcha)
    @browser.text_field(:id, 'USER_PROPERTY_owwb_ws_loginPageLogin').set username
    @browser.text_field(:id, 'USER_PROPERTY_owwb_ws_loginPagePassword').set password
    @browser.text_field(:id, 'USER_PROPERTY_owwb_ws_loginPageCaptcha').set captcha
    @browser.span(text: 'Sign in').click
  end


  def generic_info
    list = []
    @browser.lis(class: 'owwb-cs-slide-list-item').each do |item|
      title = item.span(class: 'title').text
      if /Account$/.match(title)
        item.link(class: %w(owwb-cs-slide-list-item-title owwb_cs_slideListOpen)).click
        dict = {}
        @account_number = item.lis(class: 'owwb-cs-slide-list-properties-list-property')[0].div(class: "owwb-cs-slide-list-properties-list-property-value").text.to_s.strip
        @balance = item.span(class: %w(owwb-cs-slide-list-amount-value jsMaskedElement)).text
        @currency = item.span(class: 'owwb-cs-slide-list-amount-currency').text
        @account_status = item.lis(class: 'owwb-cs-slide-list-properties-list-property')[2].div(class: "owwb-cs-slide-list-properties-list-property-value").text

        dict['name'] = @account_number
        dict['balance'] = @balance
        dict['currency'] = @currency
        dict['nature'] = @account_status
        dict['transactions'] = get_transactions(@account_number)
        list.push(dict)
      end

    end
    json_result = {}
    json_result['accounts'] = list
    puts json_result
    return json_result.to_json
  end

  def get_transactions(name)
    @browser.span(text: 'Transaction history').click
    @browser.span(text: 'Statement for accounts').click
    @browser.links(class: %w[owwb-cs-default-select owwb_cs_selectVisual])[0].click
    @browser.lis(class: 'owwb-cs-default-select-item-last')[0].click

    @browser.links(class: %w[owwb-cs-default-select owwb_cs_selectVisual])[1].click
    @browser.links(class: 'owwb-cs-default-select-item').each do |rows|
      raw_name = rows.span(class: %w[owwb-cs-default-select-item-object-text owwb_cs_itemContent]).text
      account_name = raw_name[/(MD.* ) /].to_s.strip
      if account_name == name
        rows.span(class: %w[owwb-cs-default-select-item-object-text owwb_cs_itemContent]).click
        @browser.ul(name: 'statement-base').wait_until(timeout: 10, &:present?)
        transactions_list = []
        @browser.lis(class: %w[owwb_ws_statementItem owwb_ws_statement_date_item]).each do |rows|
          date = rows.div(class: 'owwb-ws-statement-item-date').div(class: 'owwb-cs-has-tooltip').text
          time = rows.div(class: 'owwb-ws-statement-item-time').text
          description = rows.div(class: 'owwb_ws_statementItemTitle').text
          amount = rows.span(class: 'owwb-ws-statement-item-amount-value-main').text
          tt = Transaction.new(date, time, description, amount)
          transactions_list.push(tt.setup)
        end
        return transactions_list
      end
    end
  end

  def print_info
    puts @account_number, @balance, @currency, @account_status
  end
end


class Transaction
  attr_accessor :date, :time, :description, :amount

  def initialize(date, time, description, amount)
    @date = date
    @time = time
    @description = description
    @amount = amount
    @dict = {}

  end

  def setup
    @dict['date'] = date + ' ' + time
    @dict['description'] = description
    @dict['amount'] = amount
    return @dict
  end
end

site = 'https://da.victoriabank.md/frontend/auth/userlogin?execution=e2s1&locale=en'
page = Banking.new(site)
page.login
page.generic_info
page.print_info


