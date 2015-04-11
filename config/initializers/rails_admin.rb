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

    member :accept do
      link_icon 'icon-thumbs-up'
      only Abuse
      controller do
        proc do
          @object.update(status: 1)
          flash[:notice] = "Accepted  #{@object.id}"
          redirect_to rails_admin.index_path(model_name: :abuse)
        end
      end
    end

    member :decline do
      link_icon 'icon-thumbs-down'
      only Abuse
      controller do
        proc do
          @object.update(status: 2)
          flash[:notice] = "Declined  #{@object.id}"
          redirect_to rails_admin.index_path(model_name: :abuse)
        end
      end
    end

    show
    edit
    delete
    show_in_app
    collection :import_donrio do
      only Advertisement
    end

    collection :abuses do
      only Abuse
      controller do
        proc do
          @objects = Abuse.where(status: 0) || []
        end
      end
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



  config.model User do
    # edit do
    field :email, :string
    field :role, :enum do
      searchable false
      enum do
        [:owner, :agent].map { |k,_| [k.to_s.titleize, k] }
      end

      pretty_value do
        bindings[:object].send(:role).titleize
      end

      def form_value
        bindings[:object].role
      end
    end
    field :name, :string
    field :phones

    field :source, :enum do
      searchable false
      enum do
        [:unknown, :donrio, :adresat].map { |k,_| [k.to_s.titleize, k] }
      end

      pretty_value do
        bindings[:object].send(:source).titleize
      end

      def form_value
        bindings[:object].source
      end
    end


    field :advertisements do
      nested_form false
    end
  end
end
