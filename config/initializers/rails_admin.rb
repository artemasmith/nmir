RailsAdmin.config do |config|

  config.main_app_name = ['Multilisting.su']

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
    bulk_delete
    show
    edit
    delete
    show_in_app
    collection :import_donrio do
      only Advertisement
    end

    collection :import_adresat do
      only Advertisement
    end

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.navigation_static_links = {
      'sidekiq' => '/sidekiq'
  }
end
