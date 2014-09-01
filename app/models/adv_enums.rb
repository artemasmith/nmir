module AdvEnums

  extend ActiveSupport::Concern

  CATEGORIES = [
      :newbuild,
      :flat,
      :house,
      :ijs,
      :room,
      :garage,
      :office,
      :trade,
      :storage,
      :cafe,
      :land,
      :free_appointment
    ]

  ADV_TYPES = [:demand, :offer]

  OFFER_TYPES = [:sale, :rent, :for_rent, :day, :buy]

  PROPERTY_TYPES = [:commerce, :residental]

  CURRENCIES = [:RUR, :RUB]

  STATUSES = [:active, :expired]

  included do

    # enums - add values to the end of array!
    enum offer_type: AdvEnums::OFFER_TYPES

    enum category: AdvEnums::CATEGORIES

    enum property_type: AdvEnums::PROPERTY_TYPES

    enum adv_type: AdvEnums::ADV_TYPES

    enum currency: AdvEnums::CURRENCIES

    enum status_type: AdvEnums::STATUSES

  end
end
