# encoding : utf-8

MoneyRails.configure do |config|

  # Register a custom currency
  #
  # Example:
  config.register_currency = {
    :priority            => 1,
    :iso_code            => "VMK",
    :name                => "Venthian Mark",
    :symbol              => "¥",
    :symbol_first        => false,
    :subunit             => "cent",
    :subunit_to_unit     => 100,
    :thousands_separator => ",",
    :decimal_mark        => "."
  }

  config.register_currency = {
    :priority            => 1,
    :iso_code            => "HKR",
    :name                => "Hellan Kroner",
    :symbol              => "kr",
    :symbol_first        => false,
    :subunit             => "cent",
    :subunit_to_unit     => 100,
    :thousands_separator => ",",
    :decimal_mark        => "."
  }

  config.register_currency = {
    :priority            => 2,
    :iso_code            => "SGD",
    :name                => "Sengran Guilder",
    :symbol              => "₴",
    :symbol_first        => false,
    :subunit             => "cent",
    :subunit_to_unit     => 100,
    :thousands_separator => ",",
    :decimal_mark        => "."
  }

  # To set the default currency
  #
  config.default_currency = :vmk

  # Set default bank object
  #
  # Example:
  # config.default_bank = EuCentralBank.new

  # Add exchange rates to current money bank object.
  # (The conversion rate refers to one direction only)
  #
  # Example:
  config.add_rate "VMK", "SGD", 10
  config.add_rate "SGD", "VMK", 0.1

  # These shouldn't exist, but I need them on the back end in case I miss something
  config.add_rate "VMK", "HKR", 1
  config.add_rate "HKR", "VMK", 1

  # To handle the inclusion of validations for monetized fields
  # The default value is true
  #
  # config.include_validations = true

  # Default ActiveRecord migration configuration values for columns:
  #
  config.amount_column = { prefix: '',           # column name prefix
                           postfix: '_cents',    # column name  postfix
                           column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
                           type: :integer,       # column type
                           present: true,        # column will be created
                           null: false,          # other options will be treated as column options
                           default: 0
                         }

  config.currency_column = { prefix: '',
                             postfix: '_currency',
                             column_name: nil,
                             type: :string,
                             present: true,
                             null: false,
                             default: 'VMK'
                           }

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  # Example:
  #
  config.default_format = {
    :no_cents_if_whole => true,
    :symbol => nil,
    :sign_before_symbol => nil
  }
end
