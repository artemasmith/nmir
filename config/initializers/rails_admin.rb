RailsAdmin.config do |config|

  config.main_app_name = ['Nmir', 'domowoi.com']

      ### Popular gems integration

  ## == Devise ==
   config.authenticate_with do
     warden.authenticate! scope: :user
   end
  config.current_user_method &:current_user

  ## == Cancan ==
  config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show

#WTF? Update not working!
    config.model 'Advertisment' do
      edit do
        field :offer_type, :enum do
          [:sale, :rent, :for_rent, :day, :buy]
        end
        field :category, :enum do
          [
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
        end
        field :property_type, :enum do
          [:commerce, :residental]
        end
        field :offer_type, :enum do
          [:sale, :rent, :for_rent, :day, :buy]
        end
        field :currency, :enum do
          [:RUR, :RUB]
        end
        field :distance, :integer
        field :time_on_transport, :integer
        field :time_on_foot, :integer
        field :agency_id, :integer
        field :floor_from, :integer
        field :floor_to, :integer
        field :floor_cnt_from, :integer
        include_all_fields
      end
    end
  end
end
