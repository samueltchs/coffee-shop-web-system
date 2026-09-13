require_relative "validation"
# ... Add "require" statements for your own helpers here ...
require_relative "conversions"
require_relative "misc"
require_relative "local_helpers"
require_relative "urlhelpers"
require_relative "analytics"
require_relative "customer_helpers"
require_relative "employee_helpers"

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  # ... Add your own helper modules here ...
  include LocalHelpers
  include Conversions
  include UrlHelpers
  include Analytics
  include CustomerHelpers
  include EmployeeHelpers
end
