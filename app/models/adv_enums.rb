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
      :free_appointment,
      :hotel
    ]

  COMMERCE_CATEGORIES = [6, 7 ,8, 9, 10]

  RESIDENTAL_CATEGORIES = [0, 1, 2, 3 ,4 ,5, 12]



  ADV_TYPES = [:demand, :offer]

  OFFER_TYPES = [:sale, :rent, :for_rent, :day, :buy]

  PROPERTY_TYPES = [:commerce, :residental]

  STATUSES = [:active, :expired, :rejected]

  USER_ROLES = [:owner, :agent, :admin]

  ADV_SOURCES = [:unknown, :donrio, :adresat, :manual]



  included do

    enum :source => AdvEnums::ADV_SOURCES

    # enums - add values to the end of array!
    enum offer_type: AdvEnums::OFFER_TYPES

    enum category: AdvEnums::CATEGORIES

    enum property_type: AdvEnums::PROPERTY_TYPES

    enum adv_type: AdvEnums::ADV_TYPES

    enum status_type: AdvEnums::STATUSES

    enum user_role: AdvEnums::USER_ROLES

  end
end
